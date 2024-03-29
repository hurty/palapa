defmodule Palapa.Documents.Policy do
  use Palapa.Policy

  alias Palapa.Documents

  def authorize(:create_document, _member, _attrs) do
    true
  end

  def authorize(:show_document, member, document) do
    Documents.document_visible_to?(document, member)
  end

  def authorize(:update_document, member, document) do
    Documents.document_visible_to?(document, member) && !Documents.deleted?(document)
  end

  def authorize(:update_suggestion, member, suggestion) do
    suggestion.author_id == member.id && !Documents.deleted?(suggestion.document)
  end

  def authorize(:delete_suggestion, member, suggestion) do
    !Documents.deleted?(suggestion.document) &&
      (suggestion.author_id == member.id || member.role in [:admin, :owner])
  end

  def authorize(:update_suggestion_comment, member, suggestion_comment) do
    suggestion_comment.author_id == member.id
  end

  def authorize(:delete_suggestion_comment, member, suggestion_comment) do
    suggestion_comment.author_id == member.id || member.role in [:admin, :owner]
  end

  # Deny everything else
  def authorize(_, _, _) do
    false
  end
end
