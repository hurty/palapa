defmodule PalapaWeb.Document.BaseController do
  import PalapaWeb.Breadcrumbs
  alias PalapaWeb.Router.Helpers, as: Routes
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
      Routes.document_path(conn, :show, current_organization(conn), document)
    )
  end

  def put_page_breadcrumbs(conn, page) do
    conn
    |> put_document_breadcrumbs(page.document)
    |> put_breadcrumb(
      page.section.title,
      Routes.document_page_path(
        conn,
        :show,
        current_organization(conn),
        Documents.get_first_page(page.section)
      )
    )
    |> put_breadcrumb(
      page.title,
      Routes.document_page_path(conn, :show, current_organization(conn), page)
    )
  end
end
