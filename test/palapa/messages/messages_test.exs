defmodule Palapa.MessagesTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Messages
  alias Palapa.Messages.{Message, MessageComment}

  describe "messages" do
    setup do
      organization = insert!(:organization)
      member = insert!(:member, organization: organization)

      message =
        Repo.insert!(%Message{
          organization: organization,
          creator: member,
          title: "My message",
          content: "<p>Cool story</p>"
        })

      %{message: message, member: member, organization: organization}
    end

    test "get a message by id", %{message: message} do
      assert "My message" = Messages.get!(message.id).title
    end

    test "create/3 with a public message", %{member: member} do
      assert {:ok, %Message{}} =
               Messages.create(member, %{title: "Hello World", content: "<h1>Hello</h1"})
    end

    test "create/3 with a message for a specific team", %{
      member: member,
      organization: organization
    } do
      team = insert!(:team, organization: organization)

      assert {:ok, %Message{}} =
               Messages.create(member, %{title: "Hello World", content: "<h1>Hello</h1"}, [team])
    end

    test "change/1 returns a message changeset", %{message: message} do
      assert %Ecto.Changeset{} = Messages.change(message)
    end

    test "update/3 updates message attributes and teams", %{
      message: message,
      organization: organization
    } do
      team = insert!(:team, organization: organization)
      {:ok, updated_message} = Messages.update(message, %{title: "updated title"}, [team])
      assert "updated title" == updated_message.title
      assert [team] == updated_message.teams
    end

    test "delete a message", %{message: message} do
      updated_message = Messages.delete!(message)
      assert Messages.deleted?(updated_message)
    end
  end

  describe "message comments" do
    setup do
      organization = insert!(:organization)
      member = insert!(:member, organization: organization)

      message =
        Repo.insert!(%Message{
          organization: organization,
          creator: member,
          title: "My message",
          content: "<p>Cool story</p>"
        })

      comment =
        Repo.insert!(%MessageComment{
          organization: organization,
          creator: member,
          message: message,
          content: "my comment"
        })

      %{message: message, comment: comment, organization: organization, member: member}
    end

    test "get_comment!/1", %{comment: comment} do
      assert %MessageComment{} = Messages.get_comment!(comment.id)
    end

    test "create_comment/3", %{member: member, message: message} do
      {:ok, %MessageComment{} = comment} =
        Messages.create_comment(message, member, %{
          content: "My 2 cents"
        })

      assert member.organization_id == comment.organization.id
      assert member.id == comment.creator.id
      assert message.id == comment.message_id
      assert "My 2 cents" == comment.content
    end

    test "change_comment/1 returns a comment changeset", %{comment: comment} do
      assert %Ecto.Changeset{} = Messages.change_comment(comment)
    end

    test "update_comment/2 updates a comment attributes", %{comment: comment} do
      {:ok, updated_comment} = Messages.update_comment(comment, %{content: "updated content"})
      assert "updated content" == updated_comment.content
    end

    test "delete_comment!", %{comment: comment} do
      deleted_comment = Messages.delete_comment!(comment)
      assert Messages.deleted?(deleted_comment)
    end

    test "comments_count", %{message: message} do
      assert 1 == Messages.comments_count(message)
    end
  end
end
