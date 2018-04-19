defmodule Palapa.Messages.Policy do
  use Palapa.Policy

  def authorize(:create, %Member{}, _) do
    true
  end

  def authorize(:show, %Member{}, _message) do
    true
  end

  def authorize(:edit_message, %Member{} = member, message) do
    message.creator_id == member.id
  end

  def authorize(:delete_message, %Member{} = member, message) do
    is_nil(message.deleted_at) &&
      (message.creator_id == member.id || member.role in [:owner, :admin])
  end

  def authorize(:edit_comment, %Member{} = member, message_comment) do
    message_comment.creator_id == member.id
  end

  def authorize(:delete_comment, %Member{} = member, message_comment) do
    message_comment.creator_id == member.id || member.role in [:owner, :admin]
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
