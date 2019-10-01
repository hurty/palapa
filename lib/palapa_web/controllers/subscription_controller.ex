defmodule PalapaWeb.SubscriptionController do
  use PalapaWeb, :controller

  plug(:put_layout, :minimal)

  def new(conn, _params) do
    render(conn, "new.html")
  end
end
