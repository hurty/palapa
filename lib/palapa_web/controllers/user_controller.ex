defmodule PalapaWeb.UserController do
  use PalapaWeb, :controller
  alias Palapa.Accounts

  def index(conn, %{"team_id" => team_id}) do
    with :ok <- permit(Accounts, :list_users_and_teams, current_user()) do
      selected_team = Accounts.get_team!(team_id)
      users = Accounts.list_team_users(selected_team)

      teams =
        current_organization()
        |> Accounts.list_teams()

      render(conn, "index.html", %{users: users, teams: teams, selected_team: selected_team})
    end
  end

  def index(conn, _params) do
    with :ok <- permit(Accounts, :list_users_and_teams, current_user()) do
      users =
        current_organization()
        |> Accounts.list_organization_users()

      teams =
        current_organization()
        |> Accounts.list_teams()

      render(conn, "index.html", %{users: users, teams: teams, selected_team: nil})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id, current_organization())

    with :ok <-
           permit(
             Accounts,
             :get_user,
             current_user(),
             user: user,
             organization: current_organization()
           ) do
      user_teams = Accounts.list_user_teams(current_organization(), user)
      render(conn, "show.html", %{user: user, user_teams: user_teams})
    end
  end
end
