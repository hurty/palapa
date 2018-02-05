defmodule PalapaWeb.UserController do
  use PalapaWeb, :controller
  alias Palapa.Accounts

  def index(conn, %{"team_id" => team_id}, current) do
    with :ok <- permit(Accounts, :list_users_and_teams, current.user) do
      selected_team = Accounts.get_team!(team_id)
      users = Accounts.list_team_users(selected_team)

      teams =
        current.organization
        |> Accounts.list_teams()

      render(conn, "index.html", %{users: users, teams: teams, selected_team: selected_team})
    end
  end

  def index(conn, _params, current) do
    with :ok <- permit(Accounts, :list_users_and_teams, current.user) do
      users =
        current.organization
        |> Accounts.list_organization_users()

      teams =
        current.organization
        |> Accounts.list_teams()

      render(conn, "index.html", %{users: users, teams: teams, selected_team: nil})
    end
  end
end
