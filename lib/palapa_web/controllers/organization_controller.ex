defmodule PalapaWeb.OrganizationController do
  use PalapaWeb, :controller

  alias Palapa.Organizations
  alias Palapa.Organizations.Organization

  plug :put_layout, "account.html"
  plug :put_navigation, "workspaces"

  def index(conn, _) do
    organizations = current_account(conn) |> Palapa.Organizations.list_organizations()
    render(conn, "index.html", organizations: organizations)
  end

  def new(conn, _) do
    changeset = Organizations.change(%Organization{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"organization" => attrs}) do
    case Organizations.create(attrs, current_account(conn)) do
      {:ok, %{organization: organization}} ->
        redirect(conn, to: Routes.subscription_path(conn, :new, organization))

      {:error, :organization, changeset, _} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, _) do
    org = current_organization(conn)

    with :ok <- permit(Organizations.Policy, :delete_organization, current_member(conn), org) do
      case Organizations.delete(org, current_member(conn)) do
        {:ok, _organization} ->
          conn
          |> put_flash(:success, "The workspace #{org.name} has been deleted")
          |> redirect(to: Routes.organization_path(conn, :index))

        {:error, _changeset} ->
          conn
          |> put_flash(:error, "An error occurred while deleting the workspace")
          |> redirect(to: Routes.settings_workspace_path(conn, :edit, org))
      end
    end
  end
end
