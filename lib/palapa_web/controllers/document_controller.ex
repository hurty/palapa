defmodule PalapaWeb.DocumentController do
  use PalapaWeb, :controller
  alias Palapa.Documents

  plug(:put_navigation, "documents")
  plug(:put_common_breadcrumbs)

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Documents", document_path(conn, :index, current_organization()))
  end

  def index(conn, _params) do
    documents = Documents.list_documents(current_organization())
    render(conn, "index.html", documents: documents)
  end

  def new(conn, _params) do
    changeset = Documents.change_document(%Documents.Document{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"document" => document_attrs}) do
    {:ok, document} =
      Documents.create_document(current_organization(), current_member(), document_attrs)

    redirect(conn, to: document_path(conn, :show, current_organization(), document))
  end

  def show(conn, params) do
    document = Documents.get_document!(params["id"]) |> IO.inspect()

    current_page =
      if params["page_id"] do
        Documents.get_page!(params["page_id"])
      else
        Documents.get_page!(document.first_page_id)
      end

    conn
    |> put_breadcrumb(
      document.title,
      document_path(conn, :show, current_organization(), document)
    )
    |> render("show.html", document: document, current_page: current_page)
  end
end
