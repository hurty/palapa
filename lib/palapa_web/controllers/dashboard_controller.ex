defmodule PalapaWeb.DashboardController do
  use PalapaWeb, :controller
  alias Palapa.Dashboard

  def index(conn, _params) do
    with :ok <- permit(Dashboard, :index_dashboard, current_member()) do
      render(conn, "index.html")
    end
  end
end
