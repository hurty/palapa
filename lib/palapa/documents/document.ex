defmodule Palapa.Documents.Document do
  use Palapa.Schema

  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Teams.Team
  alias Palapa.Documents.{Section, Page}

  schema "documents" do
    field(:title, :string)
    field(:public, :boolean)
    timestamps()

    belongs_to(:organization, Organization)
    belongs_to(:team, Team)
    belongs_to(:last_author, Member)
    has_many(:sections, Section)
    has_many(:pages, Page)
    belongs_to(:first_page, Page)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
