defmodule PalapaWeb.Settings.Billing.PaymentAuthenticationController do
  use PalapaWeb, :controller
  plug :put_navigation, "settings"

  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb(
      "Settings",
      Routes.settings_workspace_path(conn, :show, current_organization(conn))
    )
    |> put_breadcrumb(
      "Billing",
      Routes.settings_customer_path(conn, :show, current_organization(conn))
    )
  end

  def new(conn, %{"client_secret" => client_secret}) do
    render(conn, "new.html", client_secret: client_secret)
  end
end
