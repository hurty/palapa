defmodule PalapaWeb.HomeController do
  use PalapaWeb, :controller
  alias Palapa.Beta.Subscription

  plug(:put_layout, "home.html")

  def index(conn, _params) do
    if current_account(conn) do
      redirect(conn, to: Routes.organization_path(conn, :index))
    else
      changeset = Subscription.changeset(%Subscription{}, %{})
      render(conn, "index.html", changeset: changeset)
    end
  end

  def legal(conn, _) do
    render(conn, "legal.html")
  end
end
