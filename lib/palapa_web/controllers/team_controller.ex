defmodule PalapaWeb.TeamController do
  use PalapaWeb, :controller

  alias Palapa.Teams
  alias Palapa.Teams.Team

  plug(:put_navigation, "member")

  def new(conn, _params) do
    with :ok <- permit(Teams.Policy, :create, current_member(conn)) do
      team_changeset = Teams.change(%Team{})

      conn
      |> put_breadcrumb(
        gettext("Teams"),
        Routes.member_path(conn, :index, current_organization(conn))
      )
      |> put_breadcrumb(
        gettext("New team"),
        Routes.team_path(conn, :new, current_organization(conn))
      )
      |> render("new.html", team_changeset: team_changeset)
    end
  end

  def create(conn, %{"team" => team_params}) do
    with :ok <- permit(Teams.Policy, :create, current_member(conn)) do
      case Teams.create(current_organization(conn), team_params) do
        {:ok, team} ->
          conn
          |> put_flash(
            :success,
            gettext("The team %{team} has been created!", %{team: team.name})
          )
          |> redirect(
            to: Routes.member_path(conn, :index, current_organization(conn), team_id: team.id)
          )

        {:error, team_changeset} ->
          conn
          |> put_flash(:error, gettext("The team can't be created"))
          |> render("new.html", team_changeset: team_changeset)
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    team =
      Teams.where_organization(current_organization(conn))
      |> Teams.get!(id)

    with :ok <- permit(Teams.Policy, :edit, current_member(conn), team) do
      team_changeset = Teams.change(team)

      conn
      |> put_breadcrumb(
        gettext("Your workspace"),
        Routes.member_path(conn, :index, current_organization(conn))
      )
      |> put_breadcrumb(
        team.name,
        Routes.member_path(conn, :index, current_organization(conn), team_id: team.id)
      )
      |> put_breadcrumb(
        gettext("Edit"),
        Routes.team_path(conn, :edit, current_organization(conn), team)
      )
      |> render("edit.html", team: team, team_changeset: team_changeset)
    end
  end

  def update(conn, %{"id" => id, "team" => team_params}) do
    team =
      Teams.where_organization(current_organization(conn))
      |> Teams.get!(id)

    with :ok <- permit(Teams.Policy, :update, current_member(conn), team) do
      case Teams.update(team, team_params) do
        {:ok, team} ->
          conn
          |> put_flash(:success, "The team #{team.name} has been updated!")
          |> redirect(
            to: Routes.member_path(conn, :index, current_organization(conn), team_id: team.id)
          )

        {:error, team_changeset} ->
          conn
          |> put_flash(:error, "The team can't be updated.")
          |> render("edit.html", team: team, team_changeset: team_changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    team =
      Teams.where_organization(current_organization(conn))
      |> Teams.get!(id)

    with :ok <- permit(Teams.Policy, :delete, current_member(conn), team) do
      case Teams.soft_delete(team) do
        {:ok, _} ->
          conn
          |> put_flash(:success, gettext("The team %{team} has been deleted", %{team: team.name}))
          |> redirect(to: Routes.member_path(conn, :index, current_organization(conn)))

        {:error, _} ->
          conn
          |> put_flash(
            :error,
            gettext("Unexpected error: the team %{team} couldn't be deleted", %{team: team.name})
          )
          |> redirect(to: Routes.team_path(conn, :edit, current_organization(conn), team))
      end
    end
  end
end
