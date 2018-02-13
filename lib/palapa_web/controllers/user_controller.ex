defmodule PalapaWeb.UserController do
  use PalapaWeb, :controller
  alias Palapa.Teams
  alias Palapa.Accounts

  def index(conn, %{"team_id" => team_id}) do
    with :ok <- permit(Accounts, :list, current_user()) do
      selected_team = Teams.get!(team_id)
      users = Teams.list_users(selected_team)

      teams =
        current_organization()
        |> Teams.list()

      render(conn, "index.html", %{users: users, teams: teams, selected_team: selected_team})
    end
  end

  def index(conn, _params) do
    with :ok <- permit(Accounts, :list, current_user()) do
      users =
        current_organization()
        |> Accounts.list_organization_users()

      teams =
        current_organization()
        |> Teams.list()

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
      user_teams = Teams.list_for_user(current_organization(), user)
      all_teams = Teams.list(current_organization())

      render(conn, "show.html", %{user: user, user_teams: user_teams, all_teams: all_teams})
    end
  end
end
