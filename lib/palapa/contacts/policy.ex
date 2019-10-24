defmodule Palapa.Contacts.Policy do
  use Palapa.Policy

  def authorize(:edit_comment, member, comment) do
    comment.creator.id == member.id
  end

  def authorize(:delete_comment, member, comment) do
    comment.creator.id == member.id
  end

  def authorize(_, _, _), do: false
end
