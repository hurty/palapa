defmodule Palapa.Attachments.Policy do
  use Palapa.Policy

  alias Palapa.Attachments
  alias Palapa.Organizations.MemberInformation
  alias Palapa.Messages.Message
  alias Palapa.Messages.MessageComment

  def authorize(:create, %Member{}, _) do
    true
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
      # The attachment is still an orphan, we can allow the deletion
      true
    end
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
