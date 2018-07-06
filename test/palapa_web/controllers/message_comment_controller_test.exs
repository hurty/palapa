defmodule PalapaWeb.MessageCommentControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Repo, warn: false
  alias Palapa.Messages, warn: false
  alias Palapa.Messages.{Message, MessageComment}, warn: false

  describe "as regular member" do
    setup do
      workspace = insert_pied_piper!()

      message =
        Repo.insert!(%Message{
          organization: workspace.organization,
          creator: workspace.richard,
          published_to_everyone: true,
          title: "I have a great announcement to make to everyone",
          content: "<p>This is so great</p>"
        })

      message_comment =
        Repo.insert!(%MessageComment{
          organization: workspace.organization,
          message: message,
          creator: workspace.gilfoyle,
          content: "Yes indeed"
        })

      conn = login(workspace.gilfoyle)

      {:ok, conn: conn, message_comment: message_comment}
    end

    test "the creator of a message comment can edit it", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        get(
          conn,
          message_comment_path(
            conn,
            :edit,
            message_comment.organization,
            message_comment
          )
        )

      assert html_response(conn, :ok)
    end

    test "the creator of a message comment can update it", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        patch(
          conn,
          message_comment_path(
            conn,
            :update,
            message_comment.organization,
            message_comment,
            %{"message_comment" => %{"content" => "Edited comment"}}
          )
        )

      assert html_response(conn, :ok)
    end

    test "a message comment must have content", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        patch(
          conn,
          message_comment_path(
            conn,
            :update,
            message_comment.organization,
            message_comment,
            %{"message_comment" => %{"content" => nil}}
          )
        )

      assert html_response(conn, :unprocessable_entity)
    end

    test "the creator of a message comment can delete it", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        delete(
          conn,
          message_comment_path(
            conn,
            :delete,
            message_comment.organization,
            message_comment
          )
        )

      assert html_response(conn, :ok)
    end
  end

  describe "as an admin" do
    setup do
      workspace = insert_pied_piper!()

      message =
        Repo.insert!(%Message{
          organization: workspace.organization,
          creator: workspace.richard,
          published_to_everyone: true,
          title: "I have a great announcement to make to everyone",
          content: "<p>This is so great</p>"
        })

      message_comment =
        Repo.insert!(%MessageComment{
          organization: workspace.organization,
          message: message,
          creator: workspace.jared,
          content: "Yes indeed"
        })

      conn = login(workspace.richard)

      {:ok, conn: conn, message_comment: message_comment}
    end

    test "the owner cannot edit a comment if he's not the creator", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        get(
          conn,
          message_comment_path(
            conn,
            :edit,
            message_comment.organization,
            message_comment
          )
        )

      assert html_response(conn, :forbidden)
    end

    test "The owner cannot update a comment if he's not the creator", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        patch(
          conn,
          message_comment_path(
            conn,
            :update,
            message_comment.organization,
            message_comment,
            %{"message_comment" => %{"content" => "Edited comment"}}
          )
        )

      assert html_response(conn, :forbidden)
    end

    test "the owner can delete any comment", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        delete(
          conn,
          message_comment_path(
            conn,
            :delete,
            message_comment.organization,
            message_comment
          )
        )

      assert html_response(conn, :ok)
    end
  end

  describe "as owner" do
    setup do
      workspace = insert_pied_piper!()

      message =
        Repo.insert!(%Message{
          organization: workspace.organization,
          creator: workspace.richard,
          published_to_everyone: true,
          title: "I have a great announcement to make to everyone",
          content: "<p>This is so great</p>"
        })

      message_comment =
        Repo.insert!(%MessageComment{
          organization: workspace.organization,
          message: message,
          creator: workspace.gilfoyle,
          content: "Yes indeed"
        })

      conn = login(workspace.richard)

      {:ok, conn: conn, message_comment: message_comment}
    end

    test "an admin cannot edit a comment if he's not the creator", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        get(
          conn,
          message_comment_path(
            conn,
            :edit,
            message_comment.organization,
            message_comment
          )
        )

      assert html_response(conn, :forbidden)
    end

    test "An admin cannot update a comment if he's not the creator", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        patch(
          conn,
          message_comment_path(
            conn,
            :update,
            message_comment.organization,
            message_comment,
            %{"message_comment" => %{"content" => "Edited comment"}}
          )
        )

      assert html_response(conn, :forbidden)
    end

    test "An admin can delete any comment", %{
      conn: conn,
      message_comment: message_comment
    } do
      conn =
        delete(
          conn,
          message_comment_path(
            conn,
            :delete,
            message_comment.organization,
            message_comment
          )
        )

      assert html_response(conn, :ok)
    end
  end
end
