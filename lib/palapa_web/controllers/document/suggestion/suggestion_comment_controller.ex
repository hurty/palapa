defmodule PalapaWeb.Document.SuggestionCommentController do
  use PalapaWeb, :controller

  alias Palapa.Documents.Suggestions

  def create(conn, %{
        "suggestion_id" => suggestion_id,
        "suggestion_comment" => suggestion_comment_attrs
      }) do
    suggestion =
      Suggestions.suggestions_visible_to(current_member())
      |> Suggestions.get_suggestion!(suggestion_id)

    case Suggestions.create_suggestion_comment(
           suggestion,
           current_member(),
           suggestion_comment_attrs
         ) do
      {:ok, suggestion_comment} ->
        render(conn, "suggestion_comment.html",
          layout: false,
          suggestion_comment: suggestion_comment,
          suggestion: suggestion
        )

      {:error, _changeset} ->
        send_resp(conn, 400, "An unexpected error occured while posting the suggestion comment")
    end
  end
end
