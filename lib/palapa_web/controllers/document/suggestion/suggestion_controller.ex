defmodule PalapaWeb.Document.SuggestionController do
  use PalapaWeb, :controller
  import PalapaWeb.Document.BaseController

  alias Palapa.Documents.Suggestions

  def index(conn, params) do
    page = get_page!(conn, params["page_id"])

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
    page = get_page!(conn, page_id)

    parent_suggestion =
      if suggestion_attrs["parent_suggestion_id"] do
        Suggestions.get_suggestion!(page, suggestion_attrs["parent_suggestion_id"],
          top_level: true
        )
      else
        nil
      end

    case Suggestions.create_suggestion(
           page,
           current_member(),
           parent_suggestion,
           suggestion_attrs
         ) do
      {:ok, suggestion} ->
        if parent_suggestion do
          render(conn, "reply.html", layout: false, suggestion: suggestion, page: page)
        else
          render(conn, "suggestion.html", layout: false, suggestion: suggestion, page: page)
        end

      {:error, _changeset} ->
        send_resp(conn, 400, "An unexpected error occured while posting the suggestion")
    end
  end
end
