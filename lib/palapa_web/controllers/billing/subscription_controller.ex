defmodule PalapaWeb.Billing.SubscriptionController do
  use PalapaWeb, :controller

  alias Palapa.Billing
  alias Palapa.Billing.Customer

  plug(:put_layout, :account)
  plug(:put_navigation, "workspaces")

  def new(conn, _params) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer_changeset = Billing.change_customer_infos(%Customer{})

      render(conn, "new.html", customer_changeset: customer_changeset)
    end
  end

  def create(conn, %{"customer" => customer_attrs}) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      case Billing.create_customer_and_subscription(
             current_organization(conn),
             customer_attrs
           ) do
        {:ok, result} ->
          case Billing.payment_next_action(result.stripe_subscription) do
            :requires_action ->
              client_secret =
                result.stripe_subscription["latest_invoice"]["payment_intent"]["client_secret"]

              redirect(conn,
                to:
                  Routes.payment_authentication_path(
                    conn,
                    :new,
                    current_organization(conn),
                    client_secret: client_secret
                  )
              )

            :requires_payment_method ->
              nil

            # Ask just for the card details

            :ok ->
              redirect(conn,
                to: Routes.dashboard_path(conn, :index, current_organization(conn))
              )
          end

        {:error, :customer, customer_changeset, _changes_so_far} ->
          render(conn, "new.html", customer_changeset: customer_changeset)

        {:error, :stripe_customer, _error, _changes} ->
          conn
          |> put_flash(
            :error,
            "The billing service is unreachable. Please try again or ask support"
          )
          |> redirect(to: Routes.organization_path(conn, :index))
      end
    end
  end
end
