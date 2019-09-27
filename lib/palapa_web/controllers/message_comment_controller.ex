defmodule PalapaWeb.MessageCommentController do
  use PalapaWeb, :controller
  alias Palapa.Messages

  plug(:put_navigation, "message")

  def create(conn, %{"message_id" => message_id, "message_comment" => message_comment_params}) do
    message =
      Messages.visible_to(current_member(conn))
      |> Messages.get!(message_id)

    {:ok, comment} =
      Messages.create_comment(message, current_member(conn), message_comment_params)

    comments_count = Messages.comments_count(message)

    render(
      conn,
      "create.html",
      layout: false,
      comment: comment,
      comments_count: comments_count
    )
  end

  def edit(conn, %{"id" => id}) do
    comment = Messages.get_comment!(id)
    changeset = comment |> Messages.change_comment()

    with :ok <- permit(Messages.Policy, :edit_comment, current_member(conn), comment) do
      render(
        conn,
        "_form.html",
        layout: false,
        comment: comment,
        changeset: changeset
      )
    end
  end

  def update(conn, %{"id" => id, "message_comment" => message_comment_attrs}) do
    comment = Messages.get_comment!(id)

    with :ok <- permit(Messages.Policy, :edit_comment, current_member(conn), comment) do
      case Messages.update_comment(comment, message_comment_attrs) do
        {:ok, updated_comment} ->
          conn
          |> put_status(:ok)
          |> render("_comment_content.html", layout: false, comment: updated_comment)

        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render("_form.html", layout: false, comment: comment, changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Messages.get_comment!(id)

    with :ok <- permit(Messages.Policy, :delete_comment, current_member(conn), comment) do
      Messages.delete_comment!(comment)
      message = Messages.get!(comment.message_id)
      comments_count = Messages.comments_count(message)

      render(
        conn,
        "_comments_count.html",
        layout: false,
        comments_count: comments_count
      )
    end
  end
end
