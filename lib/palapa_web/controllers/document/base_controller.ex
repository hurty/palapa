defmodule PalapaWeb.Document.BaseController do
  import PalapaWeb.Breadcrumbs
  import PalapaWeb.Router.Helpers
  import PalapaWeb.Current
  alias Palapa.Documents

  def find_document!(conn, id) do
    Documents.documents_visible_to(conn.assigns.current_member)
    |> Documents.get_document!(id)
  end

  def get_page!(conn, id) do
    Documents.pages_visible_to(conn.assigns.current_member)
    |> Documents.non_deleted()
    |> Documents.get_page!(id, conn.assigns.current_member)
  end

  def put_document_breadcrumbs(conn, document) do
    conn
    |> put_breadcrumb(
      document.title,
      document_path(conn, :show, current_organization(), document)
    )
  end

  def put_page_breadcrumbs(conn, page) do
    conn
    |> put_document_breadcrumbs(page.document)
    |> put_breadcrumb(
      page.section.title,
      document_page_path(
        conn,
        :show,
        current_organization(),
        Documents.get_first_page(page.section)
      )
    )
    |> put_breadcrumb(
      page.title,
      document_page_path(conn, :show, current_organization(), page)
    )
  end
end
