defmodule PalapaWeb.OrganizationController do
  use PalapaWeb, :controller

  plug :put_layout, "minimal.html"

  def index(conn, _) do
    organizations = current_account(conn) |> Palapa.Organizations.list_organizations()
    render(conn, "index.html", organizations: organizations)
  end
end
