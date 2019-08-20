defmodule PalapaWeb.Document.DocumentController do
  use PalapaWeb, :controller

  import PalapaWeb.Document.BaseController

  alias Palapa.Documents
  alias Palapa.Documents.{Document}
  alias Palapa.Teams

  plug :scrub_params, "document" when action in [:create, :update]

  plug :put_common_breadcrumbs
  plug :put_navigation, "documents"

  def put_common_breadcrumbs(conn, _params) do
    conn
    |> put_breadcrumb("Documents", document_path(conn, :index, current_organization()))
  end

  def index(conn, params) do
    selected_team =
      if params["team_id"] do
        Teams.where_organization(current_organization())
        |> Teams.get!(params["team_id"])
      end

    documents =
      Documents.documents_visible_to(current_member())
      |> Documents.non_deleted()
      |> Documents.documents_shared_with_team(selected_team)
      |> Documents.documents_with_search_query(params["search"])
      |> Documents.documents_sorted_by(params["sort_by"])
      |> Documents.list_documents(params["page"])

    recent_documents =
      current_member()
      |> Documents.recent_documents()

    teams = Teams.list_for_member(current_member())

    render(conn, "index.html",
      documents: documents,
      recent_documents: recent_documents,
      teams: teams,
      selected_team: selected_team
    )
  end

  def new(conn, _params) do
    changeset = Documents.change_document(%Document{})
    teams = Teams.list_for_member(current_member())

    conn
    |> put_breadcrumb("New document", document_path(conn, :new, current_organization()))
    |> render("new.html", changeset: changeset, teams: teams)
  end

  def create(conn, %{"document" => document_attrs}) do
    team = find_team(conn, document_attrs["team_id"])

    with :ok <- permit(Documents, :create_document, current_member()) do
      case Documents.create_document(current_member(), team, document_attrs) do
        {:ok, document} ->
          redirect(conn,
            to: document_path(conn, :show, current_organization(), document)
          )

        {:error, changeset} ->
          teams = Teams.list_for_member(current_member())

          conn
          |> put_breadcrumb("New document", document_path(conn, :new, current_organization()))
          |> render("new.html", changeset: changeset, teams: teams)
      end
    end
  end

  def show(conn, %{"id" => id}) do
    document = find_document!(conn, id)

    first_page = Documents.get_first_page(document)

    if first_page do
      redirect(conn,
        to: document_page_path(conn, :show, current_organization(), first_page)
      )
    else
      conn
      |> put_document_breadcrumbs(document)
      |> render("show.html",
        document: document,
        section_changeset: Documents.change_section(),
        page_changeset: Documents.change_page(),
        suggestion_changeset: Documents.Suggestions.change_suggestion()
      )
    end
  end

  def edit(conn, %{"id" => id}) do
    document = find_document!(conn, id)

    changeset = Documents.change_document(document)
    teams = Teams.list_for_member(current_member())

    conn
    |> put_document_breadcrumbs(document)
    |> put_breadcrumb(
      "Edit",
      document_path(conn, :edit, current_organization(), document)
    )
    |> render("edit.html", document: document, changeset: changeset, teams: teams)
  end

  def update(conn, %{"id" => id, "document" => document_attrs}) do
    document = find_document!(conn, id)
    team = find_team(conn, document_attrs["team_id"])

    case Documents.update_document(document, current_member(), team, document_attrs) do
      {:ok, document} ->
        redirect(conn,
          to: document_path(conn, :show, current_organization(), document)
        )

      {:error, changeset} ->
        teams = Teams.list_for_member(current_member())

        conn
        |> put_document_breadcrumbs(document)
        |> put_breadcrumb(
          "Edit",
          document_path(conn, :edit, current_organization(), document)
        )
        |> render("edit.html", document: document, changeset: changeset, teams: teams)
    end
  end

  defp find_team(conn, id) do
    if id do
      Teams.visible_to(current_member())
      |> Teams.get!(id)
    else
      nil
    end
  end
end
