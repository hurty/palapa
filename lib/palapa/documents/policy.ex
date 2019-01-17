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
    Documents.document_visible_to?(document, member)
  end

  # Deny everything else
  def authorize(_, _, _) do
    false
  end
end
