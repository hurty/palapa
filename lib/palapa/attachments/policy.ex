defmodule Palapa.Attachments.Policy do
  use Palapa.Policy

  alias Palapa.Attachments
  alias Palapa.Organizations.MemberInformation
  alias Palapa.Messages.Message
  alias Palapa.Messages.MessageComment

  def authorize(:create, %Member{}, _) do
    true
  end

  def authorize(:show, %Member{} = member, attachment) do
    if attachable = Attachments.get_attachable(attachment) do
      case attachable do
        %MemberInformation{} ->
          Palapa.Organizations.Policy.authorize(:delete_member_information, member, attachable)

        %Message{} ->
          Palapa.Messages.Policy.authorize(:show, member, attachable)

        %MessageComment{} ->
          Palapa.Messages.Policy.authorize(:show_comment, member, attachable)

        _ ->
          false
      end
    else
      # In case the attachment is an orphan, only the creator can see it
      member.id == attachment.creator_id
    end
  end

  def authorize(:delete, %Member{} = member, attachment) do
    if attachable = Attachments.get_attachable(attachment) do
      case attachable do
        %MemberInformation{} ->
          Palapa.Organizations.Policy.authorize(:delete_member_information, member, attachable)

        %Message{} ->
          Palapa.Messages.Policy.authorize(:delete_message, member, attachable)

        %MessageComment{} ->
          Palapa.Messages.Policy.authorize(:delete_comment, member, attachable)

        _ ->
          false
      end
    else
      # In case the attachment is an orphan, only the creator can delete it
      member.id == attachment.creator_id
    end
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
