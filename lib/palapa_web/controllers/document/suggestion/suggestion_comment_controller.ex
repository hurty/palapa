defmodule PalapaWeb.Document.SuggestionCommentController do
  use PalapaWeb, :controller

  alias Palapa.Documents
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

  def delete(conn, %{"id" => id}) do
    suggestion_comment = Suggestions.get_suggestion_comment!(current_organization(), id)

    with :ok <-
           permit(Documents, :delete_suggestion_comment, current_member(), suggestion_comment) do
      case Suggestions.delete_suggestion_comment(suggestion_comment) do
        {:ok, _suggestion_comment} ->
          send_resp(conn, 204, "")

        {:error, _changeset} ->
          send_resp(
            conn,
            400,
            "An unexpected error occured while deleting the suggestion comment"
          )
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    suggestion_comment = Suggestions.get_suggestion_comment!(current_organization(), id)

    with :ok <-
           permit(Documents, :delete_suggestion_comment, current_member(), suggestion_comment) do
      changeset = Suggestions.change_suggestion_comment(suggestion_comment)

      render(conn, "edit.html",
        layout: false,
        suggestion_comment: suggestion_comment,
        changeset: changeset
      )
    end
  end

  def update(conn, %{"id" => id, "suggestion_comment" => suggestion_comment_attrs}) do
    suggestion_comment = Suggestions.get_suggestion_comment!(current_organization(), id)

    with :ok <-
           permit(Documents, :update_suggestion_comment, current_member(), suggestion_comment) do
      case Suggestions.update_suggestion_comment(suggestion_comment, suggestion_comment_attrs) do
        {:ok, updated_suggestion_comment} ->
          render(conn, "suggestion_comment.html",
            layout: false,
            suggestion_comment: updated_suggestion_comment
          )

        {:error, changeset} ->
          render(conn, "edit.html",
            layout: false,
            suggestion_comment: suggestion_comment,
            changeset: changeset
          )
      end
    end
  end
end
