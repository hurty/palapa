defmodule PalapaWeb.FallbackController do
  use PalapaWeb, :controller

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> put_layout(false)
    |> put_view(PalapaWeb.ErrorView)
    |> render(:"403")
  end
end
