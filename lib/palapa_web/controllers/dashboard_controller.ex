defmodule PalapaWeb.DashboardController do
  use PalapaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
