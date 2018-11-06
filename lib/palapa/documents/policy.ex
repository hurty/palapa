defmodule Palapa.Documents.Policy do
  use Palapa.Policy

  alias Palapa.Repo
  alias Palapa.Teams

  def authorize(:create_document, member, team) do
    if team do
      Teams.member?(team, member)
    else
      true
    end
  end

  def authorize(:update_document, member, document) do
    document.public || (document.team && Teams.member?(document.team, member))
  end

  def authorize(:create_section, member, document) do
    authorize(:create_page, member, document)
  end

  def authorize(:update_section, member, section) do
    authorize(:update_document, member, section.document)
  end

  def authorize(:delete_section, member, section) do
    authorize(:update_document, member, section.document)
  end

  def authorize(:create_page, member, document) do
    document = Repo.preload(document, :team)
    document.public || (!is_nil(document.team) && Teams.member?(document.team, member))
  end

  def authorize(:edit_page, member, page) do
    page = Repo.preload(page, document: :team)
    authorize(:create_page, member, page.document)
  end

  def authorize(:move_page, member, params) do
    params.page.document_id == params.new_section.document_id &&
      authorize(:edit_page, member, params.page)
  end

  def authorize(:delete_page, member, page) do
    authorize(:update_document, member, page.document)
  end

  # Deny everything else
  def authorize(_, _, _) do
    false
  end
end
