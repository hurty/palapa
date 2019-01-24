defmodule PalapaWeb.Document.DocumentController do
  use PalapaWeb, :controller

  alias Palapa.Documents
  alias Palapa.Documents.{Document}
  alias Palapa.Teams

  plug(:put_common_breadcrumbs)
  plug(:put_navigation, "documents")

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
    render(conn, "new.html", changeset: changeset, teams: teams)
  end

  def create(conn, %{"document" => document_attrs}) do
    document_teams = find_teams(document_attrs, current_member())

    with :ok <- permit(Documents, :create_document, current_member()) do
      case Documents.create_document(current_member(), document_teams, document_attrs) do
        {:ok, document} ->
          redirect(conn,
            to: document_page_path(conn, :show, current_organization(), document.main_page_id)
          )

        {:error, changeset} ->
          teams = Teams.list_for_member(current_member())
          render(conn, "new.html", changeset: changeset, teams: teams)
      end
    end
  end

  defp find_teams(document_attrs, member) do
    teams_ids = document_attrs["publish_teams_ids"] || []

    if document_attrs["published_to_everyone"] == "false" && Enum.any?(teams_ids) do
      Teams.visible_to(member)
      |> Teams.where_ids(teams_ids)
      |> Teams.list()
    else
      []
    end
  end
end
