defmodule PalapaWeb.HomeController do
  use PalapaWeb, :controller

  plug(:put_layout, "public.html")

  def index(conn, _params) do
    if current_member() do
      redirect(conn, to: dashboard_path(conn, :index, current_organization()))
    else
      render(conn, "index.html")
    end
  end
end
