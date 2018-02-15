defmodule PalapaWeb.UserTeamController do
  use PalapaWeb, :controller
  alias Palapa.Users
  alias Palapa.Teams

  def edit(conn, %{"user_id" => user_id}) do
    with :ok <- permit(Teams, :edit_user_teams, current_user()) do
      user = Users.get!(user_id, current_organization())
      user_teams = Teams.list_for_user(current_organization(), user)
      all_teams_in_organization = Teams.list(current_organization())

      render(
        conn,
        :edit,
        user: user,
        user_teams: user_teams,
        all_teams_in_organization: all_teams_in_organization
      )
    end
  end

  def update(conn, %{"user_id" => user_id, "teams_ids" => teams_ids}) do
    user = Users.get!(user_id, current_organization())
    teams = Teams.list_by_ids(current_organization(), teams_ids)

    with :ok <-
           permit(
             Teams,
             :update_user_teams,
             current_user(),
             organization: current_organization(),
             user: user,
             teams: teams
           ) do
      Teams.update_for_user(user, teams)
      redirect(conn, to: user_path(conn, :show))
    end
  end
end
