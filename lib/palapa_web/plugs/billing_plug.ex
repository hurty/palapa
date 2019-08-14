defmodule PalapaWeb.BillingPlug do
  alias PalapaWeb.Router
  alias Palapa.Billing
  import Phoenix.Controller
  import Plug.Conn

  def enforce_billing(conn, _) do
    organization = conn.assigns[:current_organization]

    if organization && Billing.workspace_frozen?(organization) do
      conn
      |> redirect(to: Router.Helpers.settings_billing_error_path(conn, :show, organization))
      |> halt()
    else
      conn
    end
  end
end
