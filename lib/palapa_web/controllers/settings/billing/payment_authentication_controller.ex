defmodule PalapaWeb.Settings.Billing.PaymentAuthenticationController do
  use PalapaWeb, :controller
  plug :put_navigation, "settings"

  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Settings", workspace_path(conn, :show, current_organization()))
    |> put_breadcrumb("Billing", billing_path(conn, :index, current_organization()))
  end

  def new(conn, %{"client_secret" => client_secret}) do
    render(conn, "new.html", client_secret: client_secret)
  end
end
