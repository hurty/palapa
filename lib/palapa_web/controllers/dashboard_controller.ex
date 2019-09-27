defmodule PalapaWeb.DashboardController do
  use PalapaWeb, :controller
  alias Palapa.Dashboard

  plug(:put_navigation, "dashboard")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb(
      "Dashboard",
      Routes.dashboard_path(conn, :index, current_organization(conn))
    )
  end

  def index(conn, _params) do
    with :ok <- permit(Dashboard.Policy, :index_dashboard, current_member(conn)) do
      events = Palapa.Events.list_events(current_organization(conn), current_member(conn))
      render(conn, "index.html", events: events)
    end
  end
end
