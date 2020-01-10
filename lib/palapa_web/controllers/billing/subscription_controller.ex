defmodule PalapaWeb.Billing.SubscriptionController do
  require Logger
  use PalapaWeb, :controller

  alias Palapa.Billing
  alias Palapa.Billing.Customer

  plug Bodyguard.Plug.Authorize,
    policy: Palapa.Billing.Policy,
    action: :update_billing,
    user: {PalapaWeb.Current, :current_member},
    fallback: PalapaWeb.FallbackController

  plug :put_layout, :account
  plug :put_navigation, "workspaces"
  plug :put_client_secret when action in [:new, :create]

  defp put_client_secret(conn, _) do
    case Billing.create_setup_intent() do
      {:ok, setup_intent} ->
        assign(conn, :client_secret, setup_intent.client_secret)

      _ ->
        conn
        |> put_flash(
          :error,
          gettext(
            "The billing service could not process your request. Please try again or ask support"
          )
        )
        |> redirect(to: Routes.organization_path(conn, :index))
        |> halt()
    end
  end

  def new(conn, _params) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      render(conn, "new.html", customer_changeset: Billing.Customers.change_customer(%Customer{}))
    end
  end

  def create(conn, %{"customer" => customer_attrs}) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      case Billing.Subscriptions.create_subscription(
             current_organization(conn),
             customer_attrs
           ) do
        {:ok, _result} ->
          conn
          |> put_flash(:success, gettext("Thanks for your subscription!"))
          |> redirect(to: Routes.message_path(conn, :index, current_organization(conn)))

        {:error, :changeset_validation, customer_changeset, _changes_so_far} ->
          conn
          |> put_flash(:error, gettext("Please check your subscription information"))
          |> render("new.html",
            customer_changeset: customer_changeset
          )

        {:error, _, %Stripe.Error{} = stripe_error, changes} ->
          customer_changeset =
            changes.changeset_validation
            |> Map.put(:id, nil)
            |> Billing.Customers.change_customer()

          conn
          |> put_flash(:error, stripe_error.message)
          |> render("new.html",
            customer_changeset: customer_changeset
          )

        {:error, _step, _error, _changes} ->
          conn
          |> put_flash(
            :error,
            gettext(
              "The billing service could not process your request. Please try again or ask support"
            )
          )
          |> redirect(to: Routes.organization_path(conn, :index))
      end
    end
  end

  def refresh(conn, _params) do
    conn
    |> current_organization()
    |> Billing.Subscriptions.refresh_local_subscription_status()
    |> case do
      {:ok, _subscription} ->
        resp(conn, 200, gettext("subscription status has been refreshed "))

      {:error, error} ->
        Logger.error(
          gettext("subscription could not be refreshed: %{error}", %{
            error: inspect(error)
          })
        )
    end
  end
end
