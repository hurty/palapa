defmodule PalapaWeb.Settings.MemberController do
  use PalapaWeb, :controller
  alias Palapa.Organizations

  plug Bodyguard.Plug.Authorize,
    policy: Palapa.Organizations.Policy,
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
    |> put_breadcrumb(
      gettext("Settings"),
      Routes.settings_workspace_path(conn, :show, current_organization(conn))
    )
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def delete(conn, _params) do
    with :ok <-
           permit(
             Organizations.Policy,
             :leave_organization,
             current_member(conn),
             current_organization(conn)
           ) do
      Organizations.delete_member(current_member(conn))

      conn
      |> put_flash(
        :success,
        gettext("You have left %{workspace}", %{workspace: current_organization(conn).name})
      )
      |> redirect(to: Routes.organization_path(conn, :index))
    end
  end
end
