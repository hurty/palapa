defmodule PalapaWeb.Document.SuggestionController do
  use PalapaWeb, :controller
  import PalapaWeb.Document.BaseController

  alias Palapa.Documents

  def create(conn, %{"page_id" => page_id, "suggestion" => suggestion_attrs}) do
    page = get_page(conn, page_id)

    case Documents.create_suggestion(page, current_member(), nil, suggestion_attrs) do
      {:ok, suggestion} ->
        render(conn, "suggestion.html", layout: false, suggestion: suggestion)

      {:error, changeset} ->
        nil
    end
  end
end
