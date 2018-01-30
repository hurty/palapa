defmodule PalapaWeb.FallbackController do
  use PalapaWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> render(PalapaWeb.ErrorView, :"403")
  end
end
