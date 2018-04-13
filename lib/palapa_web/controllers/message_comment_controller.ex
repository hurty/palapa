defmodule PalapaWeb.MessageCommentController do
  use PalapaWeb, :controller
  alias Palapa.Messages

  plug(:put_navigation, "message")

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

  def edit(conn, %{"message_id" => message_id, "id" => id}) do
    message =
      Messages.visible_to(current_member())
      |> Messages.get!(message_id)

    comment = Messages.get_comment!(id)
    changeset = comment |> Messages.change_comment()

    with :ok <- permit(Messages, :edit_comment, current_member(), comment) do
      render(conn, "edit.html", message: message, comment: comment, changeset: changeset)
    end
  end

  def update(conn, %{
        "message_id" => message_id,
        "id" => id,
        "message_comment" => message_comment_attrs
      }) do
    message =
      Messages.visible_to(current_member())
      |> Messages.get!(message_id)

    comment = Messages.get_comment!(id)

    with :ok <- permit(Messages, :edit_comment, current_member(), comment) do
      case Messages.update_comment(comment, message_comment_attrs) do
        {:ok, _struct} ->
          redirect(conn, to: message_path(conn, :show, message))

        {:error, changeset} ->
          render(conn, "edit.html", message: message, comment: comment, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"message_id" => message_id, "id" => id}) do
    message =
      Messages.visible_to(current_member())
      |> Messages.get!(message_id)

    comment = Messages.get_comment!(id)

    with :ok <- permit(Messages, :delete_comment, current_member(), comment) do
      Messages.delete_comment!(comment)

      case get_format(conn) do
        "json" ->
          comments_count = Messages.comments_count(message)

          render(
            conn,
            "_comments_count.html",
            layout: false,
            comments_count: comments_count
          )

        "html" ->
          conn
          |> put_flash(:success, "The comment has been deleted")
          |> redirect(to: message_path(conn, :show, message))
      end
    end
  end
end
