defmodule PalapaWeb.Document.SuggestionController do
  use PalapaWeb, :controller

  alias PalapaWeb.Document.BaseController
  alias Palapa.Documents
  alias Palapa.Documents.Suggestions

  def index(conn, params) do
    page = BaseController.get_page!(conn, params["page_id"])

    suggestions =
      if(params["status"] == "closed") do
        Suggestions.closed_suggestions() |> Suggestions.list_suggestions(page)
      else
        Suggestions.open_suggestions() |> Suggestions.list_suggestions(page)
      end

    render(conn, "list.html",
      layout: false,
      suggestions: suggestions,
      page: page
    )
  end

  def create(conn, %{"page_id" => page_id, "suggestion" => suggestion_attrs}) do
    page = BaseController.get_page!(conn, page_id)

    case Suggestions.create_suggestion(
           page,
           current_member(conn),
           suggestion_attrs
         ) do
      {:ok, suggestion} ->
        render(conn, "suggestion.html", layout: false, suggestion: suggestion, page: page)

      {:error, _changeset} ->
        send_resp(conn, 400, "An unexpected error occured while posting the suggestion")
    end
  end

  def edit(conn, %{"id" => id}) do
    suggestion =
      Suggestions.suggestions_visible_to(current_member(conn))
      |> Suggestions.get_suggestion!(id)

    with :ok <- permit(Documents.Policy, :update_suggestion, current_member(conn), suggestion) do
      changeset = Suggestions.change_suggestion(suggestion)

      render(conn, "edit.html",
        layout: false,
        suggestion: suggestion,
        changeset: changeset
      )
    end
  end

  def update(conn, %{"id" => id, "suggestion" => suggestion_attrs}) do
    suggestion =
      Suggestions.suggestions_visible_to(current_member(conn))
      |> Suggestions.get_suggestion!(id)

    with :ok <- permit(Documents.Policy, :update_suggestion, current_member(conn), suggestion) do
      case Suggestions.update_suggestion(suggestion, suggestion_attrs) do
        {:ok, updated_suggestion} ->
          render(conn, "suggestion_content.html",
            layout: false,
            suggestion: updated_suggestion
          )

        {:error, changeset} ->
          render(conn, "edit.html",
            layout: false,
            suggestion: suggestion,
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    suggestion =
      Suggestions.suggestions_visible_to(current_member(conn))
      |> Suggestions.get_suggestion!(id)

    with :ok <- permit(Documents.Policy, :delete_suggestion, current_member(conn), suggestion) do
      case Suggestions.delete_suggestion(suggestion) do
        {:ok, _suggestion} ->
          send_resp(conn, 204, "")

        {:error, _changeset} ->
          send_resp(conn, 400, "An unexpected error occured while deleting the suggestion")
      end
    end
  end
end
