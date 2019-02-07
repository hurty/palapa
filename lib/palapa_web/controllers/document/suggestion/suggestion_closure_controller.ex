defmodule PalapaWeb.Document.SuggestionClosureController do
  use PalapaWeb, :controller

  alias Palapa.Documents.Suggestions

  def create(conn, %{"suggestion_id" => suggestion_id}) do
    suggestion =
      Suggestions.suggestions_visible_to(current_member())
      |> Suggestions.get_suggestion!(suggestion_id)

    case Suggestions.close_suggestion(suggestion, current_member()) do
      {:ok, _suggestion} ->
        send_resp(conn, 204, "")

      {:error, _changeset} ->
        send_resp(conn, 400, "An unexpected error occured while closing the suggestion")
    end
  end

  def delete(conn, %{"suggestion_id" => suggestion_id}) do
    suggestion =
      Suggestions.suggestions_visible_to(current_member())
      |> Suggestions.get_suggestion!(suggestion_id)

    case Suggestions.reopen_suggestion(suggestion) do
      {:ok, _suggestion} ->
        send_resp(conn, 204, "")

      {:error, _changeset} ->
        send_resp(conn, 400, "An unexpected error occured while reopening the suggestion")
    end
  end
end
