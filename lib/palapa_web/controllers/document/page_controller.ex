defmodule PalapaWeb.Document.PageController do
  use PalapaWeb, :controller

  alias PalapaWeb.Document.BaseController
  alias Palapa.Documents
  alias Palapa.Documents.Page

  plug(:put_common_breadcrumbs)
  plug(:put_navigation, "documents")

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb(
      gettext("Documents"),
      Routes.document_path(conn, :index, current_organization(conn))
    )
  end

  def new(conn, params) do
    document = Documents.get_document!(params["document_id"])

    document =
      if(Documents.document_has_at_least_one_section?(document)) do
        document
      else
        Documents.create_first_section(document, current_member(conn))
        Documents.get_document!(params["document_id"])
      end

    with :ok <- permit(Documents.Policy, :update_document, current_member(conn), document) do
      section_id = params["section_id"]
      page_changeset = Documents.change_page(%Page{}, %{section_id: section_id})
      section_changeset = Documents.change_section()

      conn
      |> BaseController.put_document_breadcrumbs(document)
      |> put_breadcrumb(
        "New page",
        Routes.document_page_path(conn, :new, current_organization(conn), document)
      )
      |> render("new.html",
        document: document,
        section_changeset: section_changeset,
        changeset: page_changeset
      )
    end
  end

  def create(conn, %{"page" => page_params}) do
    section = Documents.get_section!(page_params["section_id"])

    with :ok <- permit(Documents.Policy, :update_document, current_member(conn), section.document) do
      case Documents.create_page(section, current_member(conn), page_params) do
        {:ok, page} ->
          redirect(conn,
            to: Routes.document_page_path(conn, :show, current_organization(conn), page)
          )

        {:error, changeset} ->
          document = Documents.get_document!(section.document_id)

          conn
          |> BaseController.put_document_breadcrumbs(document)
          |> put_breadcrumb(
            "New page",
            Routes.document_page_path(conn, :new, current_organization(conn), document)
          )
          |> assign(:section_changeset, Documents.change_section())
          |> render("new.html", changeset: changeset, document: document)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    page = BaseController.get_page!(conn, id)
    previous_page = Documents.get_previous_page(page)
    next_page = Documents.get_next_page(page)
    document = Documents.get_document!(page.document_id)

    section_changeset = Documents.change_section()
    page_changeset = Documents.change_page()
    suggestion_changeset = Documents.Suggestions.change_suggestion()

    conn
    |> BaseController.put_page_breadcrumbs(page)
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
    page = BaseController.get_page!(conn, id)
    document = Documents.get_document!(page.document_id)

    with :ok <- permit(Documents.Policy, :update_document, current_member(conn), page.document) do
      conn
      |> BaseController.put_page_breadcrumbs(page)
      |> put_breadcrumb(
        "Edit",
        Routes.document_page_path(conn, :edit, current_organization(conn), page)
      )
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
    page = BaseController.get_page!(conn, id)

    with :ok <- permit(Documents.Policy, :update_document, current_member(conn), page.document) do
      case Documents.update_page(page, current_member(conn), page_params) do
        {:ok, page} ->
          redirect(conn,
            to: Routes.document_page_path(conn, :show, current_organization(conn), page)
          )

        {:error, changeset} ->
          conn
          |> BaseController.put_page_breadcrumbs(page)
          |> put_breadcrumb(
            "Edit",
            Routes.document_page_path(conn, :edit, current_organization(conn), page)
          )
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
    page = BaseController.get_page!(conn, id)

    new_section =
      Documents.sections_visible_to(current_member(conn))
      |> Documents.get_section!(new_section_id)

    with :ok <- permit(Documents.Policy, :update_document, current_member(conn), page.document) do
      case Documents.move_page(page, current_member(conn), new_section, new_position) do
        {:ok, _page} -> send_resp(conn, 200, "")
        _ -> send_resp(conn, 500, "")
      end
    end
  end

  def delete(conn, %{"id" => id, "current_page_id" => current_page_id}) do
    page = BaseController.get_page!(conn, id)

    with :ok <- permit(Documents.Policy, :update_document, current_member(conn), page.document) do
      Documents.delete_page(page, current_member(conn))

      redirect_page =
        if current_page_id == page.id do
          Documents.get_first_page(page.document)
        else
          current_page_id
        end

      conn =
        put_flash(
          conn,
          :success,
          gettext("The page \"%{page_title}\" has been deleted.", %{page_title: page.title})
        )

      if redirect_page do
        redirect(conn,
          to: Routes.document_page_path(conn, :show, current_organization(conn), redirect_page)
        )
      else
        # meaning the last page of the document has been deleted
        redirect(conn,
          to: Routes.document_path(conn, :show, current_organization(conn), page.document)
        )
      end
    end
  end
end
