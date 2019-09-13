defmodule PalapaWeb.DashboardController do
  use PalapaWeb, :controller
  alias Palapa.Dashboard

  plug(:put_navigation, "dashboard")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Dashboard", dashboard_path(conn, :index, current_organization()))
  end

  def index(conn, _params) do
    with :ok <- permit(Dashboard, :index_dashboard, current_member()) do
      events = Palapa.Events.list_events(current_organization(), current_member())
      render(conn, "index.html", events: events)
    end
  end
end
