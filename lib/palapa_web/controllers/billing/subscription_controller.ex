defmodule PalapaWeb.Billing.SubscriptionController do
  require Logger
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
        {:ok, _result} ->
          redirect(conn, to: Routes.payment_path(conn, :new, current_organization(conn)))

        {:error, :customer, customer_changeset, _changes_so_far} ->
          render(conn, "new.html", customer_changeset: customer_changeset)

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
    |> Billing.refresh_local_subscription_status()
    |> case do
      {:ok, _subscription} ->
        resp(conn, 200, "subscription status has been refreshed ")

      {:error, error} ->
        Logger.error("subscription could not be refreshed: #{inspect(error)}")
    end
  end
end
