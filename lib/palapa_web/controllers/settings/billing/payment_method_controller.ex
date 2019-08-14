defmodule PalapaWeb.Settings.Billing.PaymentMethodController do
  use PalapaWeb, :controller

  alias Palapa.Billing

  plug :put_navigation, "settings"
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Settings", settings_workspace_path(conn, :show, current_organization()))
    |> put_breadcrumb("Billing", settings_customer_path(conn, :show, current_organization()))
    |> put_breadcrumb(
      "Payment method",
      settings_payment_method_path(conn, :edit, current_organization())
    )
  end

  def edit(conn, _) do
    with :ok <- permit(Billing, :update_billing, current_member()) do
      customer = Billing.get_customer(current_organization())
      customer_changeset = Billing.change_customer_payment_method(customer)
      render(conn, "edit.html", customer_changeset: customer_changeset)
    end
  end

  def update(conn, %{"customer" => customer_attrs}) do
    with :ok <- permit(Billing, :update_billing, current_member()) do
      customer = Billing.get_customer(current_organization())

      case Billing.update_customer_payment_method(customer, customer_attrs) do
        {:ok, _result} ->
          redirect(conn, to: settings_customer_path(conn, :show, current_organization()))

        {:error, customer_changeset} ->
          render(conn, "edit.html", customer_changeset: customer_changeset)
      end
    end
  end
end
