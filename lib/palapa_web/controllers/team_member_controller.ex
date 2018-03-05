defmodule PalapaWeb.TeamMemberController do
  use PalapaWeb, :controller

  alias Palapa.Organizations
  alias Palapa.Teams

  plug(:put_navigation, "member")

  def edit(conn, %{"member_id" => member_id}) do
    with :ok <- permit(Teams, :edit_member_teams, current_member()) do
      member = Organizations.get_member!(current_organization(), member_id)
      member_teams = Teams.list_for_member(member)
      all_teams_in_organization = Teams.list(current_organization())

      render(
        conn,
        :edit,
        member: member,
        member_teams: member_teams,
        all_teams_in_organization: all_teams_in_organization
      )
    end
  end

  def update(conn, params) do
    member = Organizations.get_member!(current_organization(), params["member_id"])

    new_teams =
      if is_list(params["teams_ids"]) do
        Teams.list_by_ids(current_organization(), params["teams_ids"])
      else
        []
      end

    with :ok <-
           permit(
             Teams,
             :update_member_teams,
             current_member(),
             organization: current_organization(),
             member: member,
             teams: new_teams
           ) do
      Teams.update_all_teams_for_member(member, new_teams)
      redirect(conn, to: member_path(conn, :show, member))
    end
  end
end
