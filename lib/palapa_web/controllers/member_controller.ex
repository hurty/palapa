defmodule PalapaWeb.MemberController do
  use PalapaWeb, :controller
  alias Palapa.Teams
  alias Palapa.Organizations

  def index(conn, %{"team_id" => team_id}) do
    with :ok <- permit(Organizations, :list_members, current_member()) do
      selected_team = Teams.get!(team_id)
      members = Teams.list_members(selected_team)

      teams =
        current_organization()
        |> Teams.list()

      render(conn, "index.html", members: members, teams: teams, selected_team: selected_team)
    end
  end

  def index(conn, _params) do
    with :ok <- permit(Organizations, :list_members, current_member()) do
      members =
        current_organization()
        |> Organizations.list_members()

      teams =
        current_organization()
        |> Teams.list()

      render(conn, "index.html", members: members, teams: teams, selected_team: nil)
    end
  end

  def show(conn, %{"id" => id}) do
    member = Organizations.get_member!(current_organization(), id)

    with :ok <- permit(Organizations, :show_member, current_member()) do
      member_teams = Teams.list_for_member(member)
      all_teams = Teams.list(current_organization())

      render(
        conn,
        "show.html",
        member: member,
        member_teams: member_teams,
        all_teams: all_teams
      )
    end
  end
end
