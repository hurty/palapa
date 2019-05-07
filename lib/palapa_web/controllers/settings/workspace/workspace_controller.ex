defmodule PalapaWeb.Settings.WorkspaceController do
  use PalapaWeb, :controller

  plug :put_navigation, "settings"
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Settings", workspace_path(conn, :show, current_organization()))
  end

  def show(conn, _) do
    render(conn, "show.html")
  end
end
