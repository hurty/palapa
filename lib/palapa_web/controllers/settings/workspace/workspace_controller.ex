defmodule PalapaWeb.Settings.WorkspaceController do
  use PalapaWeb, :controller

  alias Palapa.Organizations

  plug Bodyguard.Plug.Authorize,
    policy: Palapa.Organizations.Policy,
    action: :update_organization,
    user: {PalapaWeb.Current, :current_member},
    fallback: PalapaWeb.FallbackController

  plug :put_navigation, "settings"
  plug :put_settings_navigation, "workspace"
  plug :put_common_breadcrumbs

  def put_settings_navigation(conn, value) do
    assign(conn, :settings_navigation, value)
  end

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb(
      "Settings",
      Routes.settings_workspace_path(conn, :show, current_organization(conn))
    )
  end

  def show(conn, _) do
    organization_changeset = Organizations.change(current_organization(conn))
    admins = Organizations.list_admins(current_organization(conn))

    render(conn, "show.html", organization_changeset: organization_changeset, admins: admins)
  end

  def update(conn, %{"organization" => organization_attrs}) do
    case(Organizations.update(current_organization(conn), organization_attrs)) do
      {:ok, _organization} ->
        conn
        |> put_flash(:success, gettext("Workspace settings have been saved"))
        |> redirect(to: Routes.settings_workspace_path(conn, :show, current_organization(conn)))

      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("Workspace settings could not be saved"))
        |> render("show.html", organization_changeset: changeset)
    end
  end
end
