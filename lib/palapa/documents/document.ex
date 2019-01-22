defmodule Palapa.Documents.Document do
  use Palapa.Schema

  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Teams.Team
  alias Palapa.Documents.{Section, Page, DocumentAccess}

  schema "documents" do
    field(:title, :string)
    field(:shared_with_everyone, :boolean)
    timestamps()

    belongs_to(:organization, Organization)
    belongs_to(:last_author, Member, on_replace: :delete)
    belongs_to(:main_section, Section)
    belongs_to(:main_page, Page)
    has_many(:sections, Section)
    has_many(:pages, Page)
    many_to_many(:teams, Team, join_through: "documents_teams", on_replace: :delete)
    has_many(:document_accesses, DocumentAccess)
  end

  @doc false
  def changeset(document \\ %__MODULE__{}, attrs) do
    document
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
