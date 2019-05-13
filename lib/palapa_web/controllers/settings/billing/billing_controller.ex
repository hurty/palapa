defmodule PalapaWeb.Settings.Billing.BillingController do
  use PalapaWeb, :controller

  plug :put_navigation, "settings"
  plug(:put_common_breadcrumbs)

  alias Palapa.Billing

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Settings", workspace_path(conn, :show, current_organization()))
    |> put_breadcrumb("Billing", billing_path(conn, :index, current_organization()))
  end

  def index(conn, _params) do
    with :ok <- permit(Billing, :update_billing, current_member()) do
      customer = Billing.get_customer(current_organization())
      render(conn, "index.html", customer: customer)
    end
  end

  def new(conn, _params) do
    with :ok <- permit(Billing, :update_billing, current_member()) do
      render(conn, "new.html")
    end
  end
end
