defmodule PalapaWeb.TeamMemberController do
  use PalapaWeb, :controller

  alias Palapa.Organizations
  alias Palapa.Teams

  plug(:put_navigation, "member")

  def edit(conn, %{"member_id" => member_id}) do
    with :ok <- permit(Teams.Policy, :edit_member_teams, current_member(conn)) do
      member = Organizations.get_member!(current_organization(conn), member_id)
      member_teams = Teams.list_for_member(member)

      all_teams_in_organization =
        Teams.where_organization(current_organization(conn)) |> Teams.list()

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
    member = Organizations.get_member!(current_organization(conn), params["member_id"])

    new_teams =
      if is_list(params["teams_ids"]) do
        Teams.where_organization(current_organization(conn))
        |> Teams.where_ids(params["teams_ids"])
        |> Teams.list()
      else
        []
      end

    with :ok <-
           permit(
             Teams.Policy,
             :update_member_teams,
             current_member(conn),
             organization: current_organization(conn),
             member: member,
             teams: new_teams
           ) do
      Teams.update_all_teams_for_member(member, new_teams)
      redirect(conn, to: Routes.member_path(conn, :show, current_organization(conn), member))
    end
  end
end
