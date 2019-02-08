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

    case Suggestions.create_suggestion(
           page,
           current_member(),
           suggestion_attrs
         ) do
      {:ok, suggestion} ->
        render(conn, "suggestion.html", layout: false, suggestion: suggestion, page: page)

      {:error, _changeset} ->
        send_resp(conn, 400, "An unexpected error occured while posting the suggestion")
    end
  end
end
