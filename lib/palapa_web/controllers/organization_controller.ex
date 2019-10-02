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
end
