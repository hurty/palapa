defmodule PalapaWeb.MessageCommentController do
  use PalapaWeb, :controller

  alias Palapa.Messages

  def create(conn, %{"message_id" => message_id, "message_comment" => message_comment_params}) do
    message =
      Messages.visible_to(current_member())
      |> Messages.get!(message_id)

    {:ok, comment} = Messages.create_comment(message, current_member(), message_comment_params)

    case get_format(conn) do
      "json" ->
        comments_count = Messages.comments_count(message)

        render(
          conn,
          "create.html",
          layout: false,
          comment: comment,
          comments_count: comments_count
        )

      "html" ->
        conn
        |> put_flash(:success, "Your comment has been posted")
        |> redirect(to: message_path(conn, :show, message))
    end
  end
end
