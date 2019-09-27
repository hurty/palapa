defmodule PalapaWeb.TrashController do
  use PalapaWeb, :controller

  alias Palapa.Documents

  plug(:put_navigation, "trash")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Trash", Routes.trash_path(conn, :index, current_organization()))
  end

  def index(conn, params) do
    documents =
      Documents.documents_visible_to(current_member())
      |> Documents.deleted()
      |> Documents.list_documents(params["page"])

    render(conn, "index.html", documents: documents)
  end
end
