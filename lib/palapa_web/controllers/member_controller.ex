defmodule PalapaWeb.MemberController do
  use PalapaWeb, :controller
  alias Palapa.Teams
  alias Palapa.Teams.Team
  alias Palapa.Organizations

  plug(:put_navigation, "members")

  def index(conn, %{"team_id" => team_id}) do
    with :ok <- permit(Organizations, :list_members, current_member()) do
      selected_team = Teams.get!(team_id)
      members = Teams.list_members(selected_team)
      teams = Teams.where_organization(current_organization()) |> Teams.list()
      new_team_form = Teams.change(%Team{organization: current_organization()})

      render(
        conn,
        "index.html",
        members: members,
        teams: teams,
        selected_team: selected_team,
        new_team_form: new_team_form
      )
    end
  end

  def index(conn, _params) do
    with :ok <- permit(Organizations, :list_members, current_member()) do
      members =
        current_organization()
        |> Organizations.list_members()

      teams = Teams.where_organization(current_organization()) |> Teams.list()
      new_team_form = Teams.change(%Team{organization: current_organization()})

      render(
        conn,
        "index.html",
        members: members,
        teams: teams,
        selected_team: nil,
        new_team_form: new_team_form
      )
    end
  end

  def show(conn, %{"id" => id}) do
    member = Organizations.get_member!(current_organization(), id)

    with :ok <- permit(Organizations, :show_member, current_member()) do
      member_teams = Teams.list_for_member(member)
      all_teams = Teams.where_organization(current_organization()) |> Teams.list()

      render(
        conn,
        "show.html",
        member: member,
        member_teams: member_teams,
        all_teams: all_teams
      )
    end
  end

  def edit(conn, %{"id" => id}) do
    member =
      Organizations.get_member!(current_organization(), id)
      |> Organizations.member_change()

    with :ok <- permit(Organizations, :edit_member, current_member()) do
      render(
        conn,
        "edit.html",
        member: member
      )
    end
  end

  def update(conn, %{"id" => id, "member" => member_attrs}) do
    member = Organizations.get_member!(current_organization(), id)

    with :ok <- permit(Organizations, :edit_member, current_member()) do
      case Organizations.update_member(member, member_attrs) do
        {:ok, struct} ->
          redirect(conn, to: member_path(conn, :show, struct))

        {:error, changeset} ->
          render(
            conn,
            "edit.html",
            member: changeset
          )
      end
    end
  end
end
