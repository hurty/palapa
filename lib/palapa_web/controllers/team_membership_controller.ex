defmodule PalapaWeb.TeamMembershipController do
  use PalapaWeb, :controller
  alias Palapa.Teams

  def create(conn, %{"team_id" => team_id}) do
    team = Teams.get!(team_id)

    with :ok <- permit!(Teams, :join, current_member(), team) do
      Teams.add_member(team, current_member())

      conn
      |> put_flash(:success, "You have joined the team \"#{team.name}\"")
      |> redirect(to: member_path(conn, :index, current_organization(), %{"team_id" => team.id}))
    end
  end

  def delete(conn, %{"team_id" => team_id}) do
    team = Teams.get!(team_id)

    with :ok <- permit!(Teams, :leave, current_member(), team) do
      Teams.remove_member(team, current_member())

      conn
      |> put_flash(:success, "You have left the team \"#{team.name}\"")
      |> redirect(to: member_path(conn, :index, current_organization(), %{"team_id" => team.id}))
    end
  end
end
