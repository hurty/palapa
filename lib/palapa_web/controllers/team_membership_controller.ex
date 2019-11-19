defmodule PalapaWeb.TeamMembershipController do
  use PalapaWeb, :controller
  alias Palapa.Teams

  plug(:put_navigation, "member")

  def create(conn, %{"team_id" => team_id}) do
    team = Teams.get!(team_id)

    with :ok <- permit(Teams.Policy, :join, current_member(conn), team),
         {:ok, _team} = Teams.add_member(team, current_member(conn)) do
      conn
      |> put_flash(
        :success,
        gettext("You have joined the team \"%{team}\"", %{team: team.name})
      )
      |> redirect(
        to: Routes.member_path(conn, :index, current_organization(conn), %{"team_id" => team.id})
      )
    end
  end

  def delete(conn, %{"team_id" => team_id}) do
    team = Teams.get!(team_id)

    with :ok <- permit(Teams.Policy, :leave, current_member(conn), team),
         {:ok, _team} = Teams.remove_member(team, current_member(conn)) do
      conn
      |> put_flash(
        :success,
        gettext("You have left the team \"%{team}\"", %{team: team.name})
      )
      |> redirect(
        to: Routes.member_path(conn, :index, current_organization(conn), %{"team_id" => team.id})
      )
    end
  end
end
