defmodule PalapaWeb.MemberController do
  use PalapaWeb, :controller
  alias Palapa.Teams
  alias Palapa.Organizations

  plug(:put_navigation, "members")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Your organization", member_path(conn, :index, current_organization()))
  end

  def index(conn, %{"team_id" => team_id}) do
    with :ok <- permit(Organizations, :list_members, current_member()) do
      selected_team = Teams.get!(team_id)
      members = Teams.list_members(selected_team)
      teams = Teams.where_organization(current_organization()) |> Teams.list()
      organization_members_count = current_organization() |> Organizations.members_count()

      conn
      |> put_breadcrumb(
        selected_team.name,
        member_path(conn, :index, current_organization(), team_id: team_id)
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
    with :ok <- permit(Organizations, :list_members, current_member()) do
      members =
        current_organization()
        |> Organizations.list_members()

      teams = Teams.where_organization(current_organization()) |> Teams.list()

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
    member = Organizations.get_member!(current_organization(), id)

    with :ok <- permit(Organizations, :show_member, current_member()) do
      member_teams = Teams.list_for_member(member)
      all_teams = Teams.where_organization(current_organization()) |> Teams.list()
      member_informations = Organizations.list_member_informations(member, current_member())
      member_information_changeset = Organizations.change_member_information(member)

      conn
      |> put_breadcrumb(
        member.account.name,
        member_path(conn, :show, current_organization(), member)
      )
      |> render(
        "show.html",
        member: member,
        member_teams: member_teams,
        all_teams: all_teams,
        member_informations: member_informations,
        member_information_changeset: member_information_changeset
      )
    end
  end
end
