defmodule PalapaWeb.Document.DocumentController do
  use PalapaWeb, :controller

  alias Palapa.Documents
  alias Palapa.Documents.{Document, Section, Page}

  plug(:put_common_breadcrumbs)
  plug(:put_navigation, "documents")

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Documents", document_path(conn, :index, current_organization()))
  end

  def index(conn, _params) do
    documents = Documents.list_documents(current_organization())
    render(conn, "index.html", documents: documents)
  end

  def new(conn, _params) do
    changeset = Documents.change_document(%Document{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"document" => document_attrs}) do
    {:ok, document} =
      Documents.create_document(current_organization(), current_member(), document_attrs)

    redirect(conn, to: document_path(conn, :show, current_organization(), document))
  end
end
