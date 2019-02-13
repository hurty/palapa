defmodule PalapaWeb.Document.DocumentTrashController do
  use PalapaWeb, :controller

  alias Palapa.Documents

  alias PalapaWeb.Document.DocumentView

  plug :put_common_breadcrumbs
  plug :put_navigation, "documents"

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Documents", document_path(conn, :index, current_organization()))
  end

  def create(conn, %{"document_id" => id}) do
    document = find_document(conn, id)

    Documents.delete_document!(document, current_member())

    conn
    |> put_flash(:success, DocumentView.flash_for_deleted_document(conn, document))
    |> redirect(to: document_path(conn, :index, current_organization()))
  end

  def delete(conn, %{"document_id" => id}) do
    document = find_document(conn, id)

    Documents.restore_document!(document)

    conn
    |> put_flash(:success, "The document #{document.title} has been restored.")
    |> redirect(to: document_path(conn, :show, current_organization(), document))
  end

  defp find_document(conn, id) do
    Documents.documents_visible_to(current_member())
    |> Documents.get_document!(id)
  end
end
