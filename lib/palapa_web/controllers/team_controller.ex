defmodule PalapaWeb.TeamController do
  use PalapaWeb, :controller

  alias Palapa.Teams
  alias Palapa.Teams.Team

  plug(:put_navigation, "member")

  def new(conn, _params) do
    with :ok <- permit(Teams, :create, current_member()) do
      team = Teams.change(%Team{})

      conn
      |> put_breadcrumb("People & Teams", member_path(conn, :index, current_organization()))
      |> put_breadcrumb(
        "New team",
        team_path(conn, :new, current_organization())
      )
      |> render("new.html", team: team)
    end
  end

  def create(conn, %{"team" => team_params}) do
    with :ok <- permit(Teams, :create, current_member()) do
      case Teams.create(current_organization(), team_params) do
        {:ok, team} ->
          conn
          |> put_flash(:success, "The team #{team.name} has been created!")
          |> redirect(to: member_path(conn, :index, current_organization(), team_id: team.id))

        {:error, changeset} ->
          conn
          |> put_flash(:error, "The team can't be created")
          |> render("new.html", team: changeset)
      end
    end
  end
end
