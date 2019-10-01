defmodule PalapaWeb.HomeController do
  use PalapaWeb, :controller

  plug(:put_layout, "public.html")

  def index(conn, _params) do
    if current_account(conn) do
      redirect(conn, to: Routes.organization_path(conn, :index))
    else
      render(conn, "index.html")
    end
  end
end
