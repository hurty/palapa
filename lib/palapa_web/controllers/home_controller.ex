defmodule PalapaWeb.HomeController do
  use PalapaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
