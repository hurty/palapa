defmodule PalapaWeb.TeamMemberController do
  use PalapaWeb, :controller
  alias Palapa.Organizations
  alias Palapa.Teams

  def edit(conn, %{"member_id" => member_id}) do
    with :ok <- permit(Teams, :edit_member_teams, current_member()) do
      member = Organizations.get_member!(current_organization(), member_id)
      user_teams = Teams.list_for_member(member)
      all_teams_in_organization = Teams.list(current_organization())

      render(
        conn,
        :edit,
        member: member,
        user_teams: user_teams,
        all_teams_in_organization: all_teams_in_organization
      )
    end
  end

  def update(conn, %{"member_id" => member_id, "teams_ids" => teams_ids}) do
    member = Organizations.get_member!(current_organization(), member_id)
    teams = Teams.list_by_ids(current_organization(), teams_ids)

    with :ok <-
           permit(
             Teams,
             :update_member_teams,
             current_member(),
             organization: current_organization(),
             member: member,
             teams: teams
           ) do
      # Teams.update_for_user(member, teams)
      redirect(conn, to: member_path(conn, :show, member))
    end
  end
end
