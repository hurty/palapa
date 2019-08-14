defmodule PalapaWeb.Settings.MemberController do
  use PalapaWeb, :controller

  plug Bodyguard.Plug.Authorize,
    policy: Palapa.Organizations,
    action: :update_organization,
    user: {PalapaWeb.Current, :current_member},
    fallback: PalapaWeb.FallbackController

  plug :put_navigation, "settings"
  plug :put_settings_navigation, "members"
  plug :put_common_breadcrumbs

  def put_settings_navigation(conn, value) do
    assign(conn, :settings_navigation, value)
  end

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Settings", settings_workspace_path(conn, :show, current_organization()))
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
