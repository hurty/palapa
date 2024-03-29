defmodule Palapa.Contacts.Policy do
  use Palapa.Policy

  def authorize(:edit_comment, member, comment) do
    comment.author.id == member.id
  end

  def authorize(:delete_comment, member, comment) do
    comment.author.id == member.id || member.role in [:admin, :owner]
  end

  def authorize(:export_contacts, _member, _) do
    true
  end

  def authorize(_, _, _), do: false
end
