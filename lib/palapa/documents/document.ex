defmodule Palapa.Documents.Document do
  use Palapa.Schema

  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Teams.Team
  alias Palapa.Documents.{Section, Page, DocumentAccess}

  schema "documents" do
    field(:title, :string)
    timestamps()

    belongs_to(:organization, Organization)
    belongs_to(:last_author, Member, on_replace: :update)
    belongs_to(:main_section, Section)
    belongs_to(:main_page, Page, on_replace: :update)
    belongs_to(:team, Team, on_replace: :update)
    has_many(:sections, Section)
    has_many(:pages, Page)
    has_many(:document_accesses, DocumentAccess)
  end

  @doc false
  def changeset(document \\ %__MODULE__{}, attrs) do
    document
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
