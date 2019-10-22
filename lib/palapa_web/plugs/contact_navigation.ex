defmodule PalapaWeb.ContactNavigation do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _params) do
    conn
    |> assign(:navigation, "contacts")
  end
end
