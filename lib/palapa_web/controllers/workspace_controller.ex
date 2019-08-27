defmodule PalapaWeb.WorkspaceController do
  use PalapaWeb, :controller

  plug(:put_layout, "minimal.html")

  def index(conn, _) do
    organizations = []
    render(conn, "index.html", organizations: organizations)
  end
end
