defmodule PalapaWeb.Document.PageController do
  use PalapaWeb, :controller
  import PalapaWeb.Document.BaseController

  alias Palapa.Documents
  alias Palapa.Documents.Page

  plug(:put_common_breadcrumbs)
  plug(:put_navigation, "documents")

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Documents", document_path(conn, :index, current_organization()))
  end

  def new(conn, params) do
    document = Documents.get_document!(params["document_id"])

    with :ok <- permit(Documents, :update_document, current_member(), document) do
      section_id = params["section_id"] || document.main_section_id
      page_changeset = Documents.change_page(%Page{}, %{section_id: section_id})
      section_changeset = Documents.change_section()

      conn
      |> render("new.html",
        document: document,
        section_changeset: section_changeset,
        changeset: page_changeset
      )
    end
  end

  def create(conn, %{"page" => page_params}) do
    section = Documents.get_section!(page_params["section_id"])

    with :ok <- permit(Documents, :update_document, current_member(), section.document) do
      case Documents.create_page(section, current_member(), page_params) do
        {:ok, page} ->
          redirect(conn, to: document_page_path(conn, :show, current_organization(), page))

        {:error, changeset} ->
          document = Documents.get_document!(section.document_id)

          conn
          |> assign(:section_changeset, Documents.change_section())
          |> render("new.html", changeset: changeset, document: document)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    page = get_page!(conn, id)
    previous_page = Documents.get_previous_page(page)
    next_page = Documents.get_next_page(page)
    document = Documents.get_document!(page.document_id)

    section_changeset = Documents.change_section()
    page_changeset = Documents.change_page()
    suggestion_changeset = Documents.Suggestions.change_suggestion()

    conn
    |> put_breadcrumb(
      document.title,
      document_path(conn, :show, current_organization(), document)
    )
    |> render("show.html",
      page: page,
      previous_page: previous_page,
      next_page: next_page,
      document: document,
      section_changeset: section_changeset,
      page_changeset: page_changeset,
      suggestion_changeset: suggestion_changeset
    )
  end

  def edit(conn, %{"id" => id}) do
    page = get_page!(conn, id)
    document = Documents.get_document!(page.document_id)

    with :ok <- permit(Documents, :update_document, current_member(), page.document) do
      conn
      |> render("edit.html",
        document: document,
        page: page,
        section_changeset: Documents.change_section(),
        page_changeset: Documents.change_page(),
        changeset: Documents.change_page(page)
      )
    end
  end

  def update(conn, %{"id" => id, "page" => page_params}) do
    page = get_page!(conn, id)

    with :ok <- permit(Documents, :update_document, current_member(), page.document) do
      case Documents.update_page(page, current_member(), page_params) do
        {:ok, page} ->
          redirect(conn, to: document_page_path(conn, :show, current_organization(), page))

        {:error, changeset} ->
          conn
          |> assign(:section_changeset, Documents.change_section())
          |> assign(:page_changeset, Documents.change_page())
          |> assign(:changeset, changeset)
          |> render("edit.html", document: page.document, page: page)
      end
    end
  end

  def update(conn, %{
        "id" => id,
        "new_section_id" => new_section_id,
        "new_position" => new_position
      }) do
    page = get_page!(conn, id)

    new_section =
      Documents.sections_visible_to(current_member())
      |> Documents.get_section!(new_section_id)

    with :ok <- permit(Documents, :update_document, current_member(), page.document) do
      Documents.move_page!(page, new_section, new_position)
      send_resp(conn, 200, "")
    end
  end

  def delete(conn, %{"id" => id, "current_page_id" => current_page_id}) do
    page = get_page!(conn, id)

    with :ok <- permit(Documents, :update_document, current_member(), page.document) do
      Documents.delete_page!(page)

      redirect_page =
        if current_page_id == page.id do
          page.document.main_page_id
        else
          current_page_id
        end

      conn
      |> put_flash(:success, "The page \"#{page.title}\" has been deleted.")
      |> redirect(to: document_page_path(conn, :show, current_organization(), redirect_page))
    end
  end
end
