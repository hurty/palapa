defmodule PalapaWeb.UserController do
  use PalapaWeb, :controller

  alias Palapa.Accounts

  def index(conn, %{"team_id" => team_id}) do
    selected_team = Accounts.get_team!(team_id)
    users = Accounts.list_team_users(selected_team)

    teams = 
      conn
      |> current_organization
      |> Accounts.list_organization_teams

    render(conn, "index.html", %{users: users, teams: teams, selected_team: selected_team})
  end

  def index(conn, _params) do
    users = 
      conn
      |> current_organization
      |> Accounts.list_organization_users

    teams = 
      conn
      |> current_organization
      |> Accounts.list_organization_teams

    render(conn, "index.html", %{users: users, teams: teams, selected_team: nil})
  end
end