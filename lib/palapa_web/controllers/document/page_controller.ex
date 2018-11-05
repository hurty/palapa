defmodule PalapaWeb.Document.PageController do
  use PalapaWeb, :controller

  alias Palapa.Documents

  plug(:put_common_breadcrumbs)
  plug(:put_navigation, "documents")

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Documents", document_path(conn, :index, current_organization()))
  end

  def show(conn, %{"id" => id}) do
    page = Documents.get_page!(id)
    document = Documents.get_document!(page.document_id)

    section_changeset = Documents.change_section()
    page_changeset = Documents.change_page()

    conn
    |> put_breadcrumb(
      document.title,
      document_path(conn, :show, current_organization(), document)
    )
    |> render("show.html",
      document: document,
      page: page,
      section_changeset: section_changeset,
      page_changeset: page_changeset
    )
  end

  def create(conn, %{"document_id" => document_id, "page" => page_params}) do
    document = Documents.get_document!(document_id)

    with :ok <- permit(Documents, :create_page, current_member(), document) do
      case Documents.create_page(document, document.main_section, current_member(), page_params) do
        {:ok, page} -> render(conn, "page.html", layout: false, page: page)
        _ -> send_resp(conn, 400, "")
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    page = Documents.get_page!(id)
    document = Documents.get_document!(page.document_id)

    with :ok <- permit(Documents, :edit_page, current_member(), page) do
      conn
      |> assign(:section_changeset, Documents.change_section())
      |> assign(:page_changeset, Documents.change_page())
      |> assign(:changeset, Documents.change_page(page))
      |> render("edit.html", document: document, page: page)
    end
  end

  def update(conn, %{"id" => id, "page" => page_params}) do
    page = Documents.get_page!(id)
    document = Documents.get_document!(page.document_id)

    with :ok <- permit(Documents, :edit_page, current_member(), page) do
      case Documents.update_page(page, page_params) do
        {:ok, page} ->
          redirect(conn, to: document_page_path(conn, :show, current_organization(), page))

        {:error, changeset} ->
          conn
          |> assign(:section_changeset, Documents.change_section())
          |> assign(:page_changeset, Documents.change_page())
          |> assign(:changeset, changeset)
          |> render("edit.html", document: document, page: page)
      end
    end
  end

  def update(conn, %{
        "id" => id,
        "new_section_id" => new_section_id,
        "new_position" => new_position
      }) do
    page = Documents.get_page!(id)
    new_section = Documents.get_section!(new_section_id)

    with :ok <-
           permit(Documents, :move_page, current_member(),
             page: page,
             new_section: new_section,
             new_position: new_position
           ) do
      Documents.move_page!(page, new_section, new_position)
      send_resp(conn, 200, "")
    end
  end
end
