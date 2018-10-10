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

  def authorize(:create_section, member, document) do
    document = Repo.preload(document, :team)
    document.public || (!is_nil(document.team) && Teams.member?(document.team, member))
  end

  # Deny everything else
  def authorize(_, _, _) do
    false
  end
end
