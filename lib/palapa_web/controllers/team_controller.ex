defmodule PalapaWeb.TeamController do
  use PalapaWeb, :controller

  alias Palapa.Teams
  alias Palapa.Teams.Team

  plug(:put_navigation, "member")

  def new(conn, _params) do
    with :ok <- permit(Teams, :create, current_member()) do
      team = Teams.change(%Team{})
      render(conn, :new, team: team)
    end
  end

  def create(conn, %{"team" => team_params}) do
    with :ok <- permit(Teams, :create, current_member()) do
      case Teams.create(current_organization(), team_params) do
        {:ok, team} ->
          put_flash(conn, :success, "The team #{team.name} has been created!")
          |> redirect(to: member_path(conn, :index, team_id: team.id))

        {:error, changeset} ->
          put_flash(conn, :error, "The team can't be created")
          |> render(:new, team: changeset)
      end
    end
  end
end
