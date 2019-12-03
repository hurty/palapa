defmodule PalapaWeb.DisableFeature do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _options) do
    halt(conn)
  end
end
