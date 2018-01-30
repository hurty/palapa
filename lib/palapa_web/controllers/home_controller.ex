defmodule PalapaWeb.HomeController do
  use PalapaWeb, :controller

  plug(:put_layout, "public.html")

  def index(conn, _params, _current_user, _current_organization) do
    render(conn, "index.html")
  end
end
