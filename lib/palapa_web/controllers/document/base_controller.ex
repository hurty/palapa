defmodule PalapaWeb.Document.BaseController do
  alias Palapa.Documents

  def get_page(conn, id) do
    Documents.pages_visible_to(conn.assigns.current_member)
    |> Documents.get_page!(id, conn.assigns.current_member)
  end
end
