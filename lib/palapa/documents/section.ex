defmodule Palapa.Documents.Section do
  use Palapa.Schema
  alias Palapa.Documents.{Document, Page}
  alias Palapa.Organizations.{Member}

  schema "sections" do
    field(:title, :string)
    field(:position, :integer)
    timestamps()

    belongs_to(:document, Document)
    belongs_to(:last_author, Member)
    has_one(:team, through: [:document, :team])
    has_many(:pages, Page)

    field(:deleted_at, :utc_datetime)
    belongs_to(:deletion_author, Member, on_replace: :update)
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title, :position])
    |> validate_required([:title])
  end
end
