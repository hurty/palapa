defmodule PalapaWeb.MessageControllerTest do
  use PalapaWeb.ConnCase

  alias Palapa.Repo, warn: false
  alias Palapa.Messages, warn: false
  alias Palapa.Messages.Message, warn: false

  describe "as regular member" do
    setup do
      workspace = insert_pied_piper!()

      public_message =
        insert!(
          :message,
          organization: workspace.organization,
          creator: workspace.richard,
          published_to_everyone: true,
          title: "I have a great announcement to make to everyone",
          content: "<p>This is so great</p>"
        )

      tech_message =
        insert!(
          :message,
          organization: workspace.organization,
          creator: workspace.gilfoyle,
          published_to_everyone: false,
          teams: [workspace.tech_team],
          title: "I have a great announcement for tech people",
          content: "<p>This is so fun</p>"
        )

      management_message =
        insert!(
          :message,
          organization: workspace.organization,
          creator: workspace.jared,
          published_to_everyone: false,
          teams: [workspace.management_team],
          title: "I have a sad announcement for the managers",
          content: "<p>This is so sad</p>"
        )

      workspace =
        Map.put_new(workspace, :messages, %{
          public_message: public_message,
          tech_message: tech_message,
          management_message: management_message
        })

      conn = login(workspace.gilfoyle)

      {:ok, conn: conn, workspace: workspace}
    end

    test "list only messages the member has the right to see (public + his teams)", %{
      conn: conn,
      workspace: workspace
    } do
      conn = get(conn, message_path(conn, :index, workspace.organization))
      assert html_response(conn, 200) =~ "I have a great announcement to make to everyone"
      assert html_response(conn, 200) =~ "I have a great announcement for tech people"
      refute html_response(conn, 200) =~ "I have a sad announcement for the managers"
    end

    test "a regular member can display a message published to everyone", %{
      conn: conn,
      workspace: workspace
    } do
      path = message_path(conn, :show, workspace.organization, workspace.messages.public_message)
      conn = get(conn, path)

      assert html_response(conn, 200) =~ "I have a great announcement to make to everyone"
    end

    test "a regular member can't edit a message published to a team he's not a member of", %{
      conn: conn,
      workspace: workspace
    } do
      path =
        message_path(conn, :edit, workspace.organization, workspace.messages.management_message)

      assert_error_sent(:not_found, fn ->
        get(conn, path)
      end)
    end

    test "a regular member can edit a message if he is the creator", %{
      conn: conn,
      workspace: workspace
    } do
      path = message_path(conn, :edit, workspace.organization, workspace.messages.tech_message)
      conn = get(conn, path)
      assert html_response(conn, 200)
    end

    test "a regular member cannot edit a message if he is not the creator", %{
      conn: conn,
      workspace: workspace
    } do
      path = message_path(conn, :edit, workspace.organization, workspace.messages.public_message)
      conn = get(conn, path)

      assert html_response(conn, :forbidden)
    end

    test "a regular member can update a message if he is the creator", %{
      conn: conn,
      workspace: workspace
    } do
      path = message_path(conn, :update, workspace.organization, workspace.messages.tech_message)
      conn = patch(conn, path, %{"message" => %{"title" => "Updated title"}})
      updated_message = Repo.reload(workspace.messages.tech_message)

      assert redirected_to(conn, 302) =~
               message_path(conn, :show, workspace.organization, updated_message)

      assert updated_message.title == "Updated title"
    end

    test "a regular member cannot update a message if he is not the creator", %{
      conn: conn,
      workspace: workspace
    } do
      path =
        message_path(conn, :update, workspace.organization, workspace.messages.public_message)

      conn = patch(conn, path, %{"message" => %{"title" => "Updated title"}})

      assert html_response(conn, :forbidden)
    end

    test "a regular member can delete his own message", %{conn: conn, workspace: workspace} do
      path = message_path(conn, :delete, workspace.organization, workspace.messages.tech_message)
      conn = delete(conn, path)

      assert Messages.deleted?(Repo.reload(workspace.messages.tech_message))
      assert redirected_to(conn, 302) =~ message_path(conn, :index, workspace.organization)
    end

    test "a regular member cannot delete someone else's message", %{
      conn: conn,
      workspace: workspace
    } do
      path =
        message_path(conn, :delete, workspace.organization, workspace.messages.public_message)

      conn = delete(conn, path)

      refute Messages.deleted?(Repo.reload(workspace.messages.public_message))
      assert html_response(conn, :forbidden)
    end
  end

  describe "as the owner" do
    setup do
      workspace = insert_pied_piper!()

      tech_message =
        insert!(
          :message,
          organization: workspace.organization,
          creator: workspace.gilfoyle,
          published_to_everyone: false,
          teams: [workspace.tech_team],
          title: "I have a great announcement for tech people",
          content: "<p>This is so fun</p>"
        )

      workspace =
        Map.put_new(workspace, :messages, %{
          tech_message: tech_message
        })

      conn = login(workspace.richard)

      {:ok, conn: conn, workspace: workspace}
    end

    test "the owner can delete any message", %{conn: conn, workspace: workspace} do
      path = message_path(conn, :delete, workspace.organization, workspace.messages.tech_message)
      conn = delete(conn, path)

      assert Messages.deleted?(Repo.reload(workspace.messages.tech_message))
      assert redirected_to(conn, 302) =~ message_path(conn, :index, workspace.organization)
    end
  end

  describe "as an admin" do
    setup do
      workspace = insert_pied_piper!()

      tech_message =
        insert!(
          :message,
          organization: workspace.organization,
          creator: workspace.gilfoyle,
          published_to_everyone: false,
          teams: [workspace.tech_team],
          title: "I have a great announcement for tech people",
          content: "<p>This is so fun</p>"
        )

      workspace =
        Map.put_new(workspace, :messages, %{
          tech_message: tech_message
        })

      conn = login(workspace.jared)

      {:ok, conn: conn, workspace: workspace}
    end

    test "an admin can delete any message", %{conn: conn, workspace: workspace} do
      path = message_path(conn, :delete, workspace.organization, workspace.messages.tech_message)
      conn = delete(conn, path)

      assert Messages.deleted?(Repo.reload(workspace.messages.tech_message))
      assert redirected_to(conn, 302) =~ message_path(conn, :index, workspace.organization)
    end
  end
end
