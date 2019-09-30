defmodule PalapaWeb.HomeController do
  use PalapaWeb, :controller

  alias Palapa.Accounts

  plug(:put_layout, "public.html")

  def index(conn, _params) do
    if current_account(conn) do
      organization = Accounts.main_organization(current_account(conn))
      redirect(conn, to: Routes.dashboard_path(conn, :index, organization))
    else
      render(conn, "index.html")
    end
  end
end
