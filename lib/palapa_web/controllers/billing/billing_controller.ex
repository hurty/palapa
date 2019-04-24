defmodule PalapaWeb.Billing.BillingController do
  use PalapaWeb, :controller

  plug(:put_layout, "minimal.html")

  def index(conn, %{"organization_id" => _organization_id}) do
    render(conn, "index.html")
  end
end
