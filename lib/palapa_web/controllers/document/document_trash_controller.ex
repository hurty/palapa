defmodule PalapaWeb.Document.DocumentTrashController do
  use PalapaWeb, :controller

  alias Palapa.Documents

  alias PalapaWeb.Document.DocumentView

  plug :put_common_breadcrumbs
  plug :put_navigation, "documents"

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb(
      gettext("Documents"),
      Routes.document_path(conn, :index, current_organization(conn))
    )
  end

  def create(conn, %{"document_id" => id}) do
    document = find_document(conn, id)

    Documents.delete_document!(document, current_member(conn))

    conn
    |> put_flash(:success, DocumentView.flash_for_deleted_document(conn, document))
    |> redirect(to: Routes.document_path(conn, :index, current_organization(conn)))
  end

  def delete(conn, %{"document_id" => id}) do
    document = find_document(conn, id)

    Documents.restore_document!(document)

    conn
    |> put_flash(
      :success,
      gettext("The document %{document_title} has been restored.", %{
        document_title: document.title
      })
    )
    |> redirect(to: Routes.document_path(conn, :show, current_organization(conn), document))
  end

  defp find_document(conn, id) do
    Documents.documents_visible_to(current_member(conn))
    |> Documents.get_document!(id)
  end
end
