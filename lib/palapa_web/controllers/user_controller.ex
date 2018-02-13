defmodule PalapaWeb.UserController do
  use PalapaWeb, :controller
  alias Palapa.Users
  alias Palapa.Teams
  alias Palapa.Organizations

  def index(conn, %{"team_id" => team_id}) do
    with :ok <- permit(Users, :list, current_user()) do
      selected_team = Teams.get!(team_id)
      users = Teams.list_users(selected_team)

      teams =
        current_organization()
        |> Teams.list()

      render(conn, "index.html", %{users: users, teams: teams, selected_team: selected_team})
    end
  end

  def index(conn, _params) do
    with :ok <- permit(Users, :list, current_user()) do
      users =
        current_organization()
        |> Organizations.list_users()

      teams =
        current_organization()
        |> Teams.list()

      render(conn, "index.html", %{users: users, teams: teams, selected_team: nil})
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get!(id, current_organization())

    with :ok <-
           permit(
             Users,
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
