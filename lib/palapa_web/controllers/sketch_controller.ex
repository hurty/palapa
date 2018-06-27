defmodule PalapaWeb.SketchController do
  use PalapaWeb, :controller

  plug(:put_navigation, "sketch")

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
