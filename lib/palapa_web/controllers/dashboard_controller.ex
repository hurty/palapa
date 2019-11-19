defmodule PalapaWeb.DashboardController do
  use PalapaWeb, :controller
  alias Palapa.Dashboard
  alias Palapa.Messages
  alias Palapa.Teams

  plug(:put_navigation, "dashboard")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb(
      "Dashboard",
      Routes.dashboard_path(conn, :index, current_organization(conn))
    )
  end

  def index(conn, params) do
    with :ok <- permit(Dashboard.Policy, :index_dashboard, current_member(conn)) do
      events = Palapa.Events.last_50_events(current_organization(conn), current_member(conn))

      selected_team =
        if params["team_id"] do
          Teams.where_organization(current_organization(conn))
          |> Teams.get!(params["team_id"])
        end

      messages =
        Messages.visible_to(current_member(conn))
        |> filter_team(selected_team)
        |> Messages.paginate(params["page"])

      teams = Teams.list_for_member(current_member(conn))

      render(conn, "index.html",
        events: events,
        messages: messages,
        teams: teams,
        selected_team: selected_team
      )
    end
  end

  defp filter_team(query, team) do
    if team do
      query
      |> Messages.published_to(team)
    else
      query
    end
  end
end
