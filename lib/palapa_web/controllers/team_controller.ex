defmodule PalapaWeb.TeamController do
  use PalapaWeb, :controller

  alias Palapa.Teams
  alias Palapa.Teams.Team

  plug(:put_navigation, "member")

  def new(conn, _params) do
    with :ok <- permit(Teams, :create, current_member()) do
      team_changeset = Teams.change(%Team{})

      conn
      |> put_breadcrumb(
        "Your organization",
        Routes.member_path(conn, :index, current_organization())
      )
      |> put_breadcrumb(
        "New team",
        Routes.team_path(conn, :new, current_organization())
      )
      |> render("new.html", team_changeset: team_changeset)
    end
  end

  def create(conn, %{"team" => team_params}) do
    with :ok <- permit(Teams, :create, current_member()) do
      case Teams.create(current_organization(), team_params) do
        {:ok, team} ->
          conn
          |> put_flash(:success, "The team #{team.name} has been created!")
          |> redirect(
            to: Routes.member_path(conn, :index, current_organization(), team_id: team.id)
          )

        {:error, team_changeset} ->
          conn
          |> put_flash(:error, "The team can't be created")
          |> render("new.html", team_changeset: team_changeset)
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    team =
      Teams.where_organization(current_organization())
      |> Teams.get!(id)

    with :ok <- permit(Teams, :edit, current_member(), team) do
      team_changeset = Teams.change(team)

      conn
      |> put_breadcrumb(
        "Your organization",
        Routes.member_path(conn, :index, current_organization())
      )
      |> put_breadcrumb(
        team.name,
        Routes.member_path(conn, :index, current_organization(), team_id: team.id)
      )
      |> put_breadcrumb("Edit", Routes.team_path(conn, :edit, current_organization(), team))
      |> render("edit.html", team: team, team_changeset: team_changeset)
    end
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team =
      Teams.where_organization(current_organization())
      |> Teams.get!(id)

    with :ok <- permit(Teams, :update, current_member(), team) do
      case Teams.update(team, team_params) do
        {:ok, team} ->
          conn
          |> put_flash(:success, "The team #{team.name} has been updated!")
          |> redirect(
            to: Routes.member_path(conn, :index, current_organization(), team_id: team.id)
          )

        {:error, team_changeset} ->
          conn
          |> put_flash(:error, "The team can't be updated.")
          |> render("edit.html", team: team, team_changeset: team_changeset)
      end
    end
  end
end
