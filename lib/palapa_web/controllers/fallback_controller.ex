defmodule PalapaWeb.FallbackController do
  use PalapaWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_layout(false)
    |> render(PalapaWeb.ErrorView, :"403")
  end
end
