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

  plug(:put_layout, :account)
  plug(:put_navigation, "workspaces")

  def new(conn, _params) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer_changeset = Billing.Customers.change_customer(%Customer{})

      render(conn, "new.html",
        customer_changeset: customer_changeset,
        setup_intent: setup_intent()
      )
    end
  end

  def create(conn, %{"customer" => customer_attrs}) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      case Billing.Subscriptions.create_subscription(
             current_organization(conn),
             customer_attrs
           ) do
        {:ok, _result} ->
          redirect(conn, to: Routes.payment_path(conn, :new, current_organization(conn)))

        {:error, :changeset_validation, customer_changeset, _changes_so_far} ->
          conn
          |> put_flash(:error, "Please check your subscription information")
          |> render("new.html",
            customer_changeset: customer_changeset,
            setup_intent: setup_intent()
          )

        {:error, _, %Stripe.Error{} = stripe_error, changes} ->
          customer_changeset =
            changes.changeset_validation
            |> Map.put(:id, nil)
            |> Billing.Customers.change_customer()

          conn
          |> put_flash(:error, stripe_error.message)
          |> render("new.html",
            customer_changeset: customer_changeset,
            setup_intent: setup_intent()
          )

        {:error, _step, _error, _changes} ->
          conn
          |> put_flash(
            :error,
            "The billing service could not process your request. Please try again or ask support"
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
        resp(conn, 200, "subscription status has been refreshed ")

      {:error, error} ->
        Logger.error("subscription could not be refreshed: #{inspect(error)}")
    end
  end

  defp setup_intent do
    {:ok, setup_intent} = Billing.create_setup_intent()
    setup_intent
  end
end
