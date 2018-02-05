defmodule PalapaWeb.DashboardController do
  use PalapaWeb, :controller
  alias Palapa.Dashboard

  def index(conn, _params, current) do
    with :ok <- permit(Dashboard, :index_dashboard, current.user) do
      render(conn, "index.html")
    end
  end
end
