defmodule Palapa.Documents.Section do
  use Palapa.Schema
  alias Palapa.Documents.{Document, Page}
  alias Palapa.Organizations

  schema "sections" do
    field(:title, :string)
    field(:position, :integer)
    field(:deleted_at, :utc_datetime)
    timestamps()

    belongs_to(:document, Document)
    belongs_to(:last_author, Organizations.Member)
    has_many(:pages, Page)
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title, :position])
    |> validate_required([:title])
  end
end
