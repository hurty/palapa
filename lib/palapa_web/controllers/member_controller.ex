defmodule PalapaWeb.MemberController do
  use PalapaWeb, :controller
  alias Palapa.Teams
  alias Palapa.Organizations

  plug(:put_navigation, "members")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb(
      "Your organization",
      Routes.member_path(conn, :index, current_organization(conn))
    )
  end

  def index(conn, %{"team_id" => team_id}) do
    with :ok <- permit(Organizations.Policy, :list_members, current_member(conn)) do
      selected_team = Teams.get!(team_id)
      members = Teams.list_members(selected_team)
      teams = Teams.where_organization(current_organization(conn)) |> Teams.list()
      organization_members_count = current_organization(conn) |> Organizations.members_count()

      conn
      |> put_breadcrumb(
        selected_team.name,
        Routes.member_path(conn, :index, current_organization(conn), team_id: team_id)
      )
      |> render(
        "index.html",
        members: members,
        teams: teams,
        selected_team: selected_team,
        organization_members_count: organization_members_count
      )
    end
  end

  def index(conn, _params) do
    with :ok <- permit(Organizations.Policy, :list_members, current_member(conn)) do
      members =
        current_organization(conn)
        |> Organizations.list_members()

      teams = Teams.where_organization(current_organization(conn)) |> Teams.list()

      conn
      |> render(
        "index.html",
        members: members,
        teams: teams,
        selected_team: nil,
        organization_members_count: length(members)
      )
    end
  end

  def show(conn, %{"id" => id}) do
    member = Organizations.get_member!(current_organization(conn), id)

    with :ok <- permit(Organizations.Policy, :show_member, current_member(conn)) do
      all_teams = Teams.where_organization(current_organization(conn)) |> Teams.list()

      conn
      |> put_breadcrumb(
        member.account.name,
        Routes.member_path(conn, :show, current_organization(conn), member)
      )
      |> render(
        "show.html",
        member: member,
        all_teams: all_teams
      )
    end
  end
end
