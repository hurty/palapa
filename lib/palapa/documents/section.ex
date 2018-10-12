defmodule Palapa.Documents.Section do
  use Palapa.Schema

  alias Palapa.Documents.{Document, Page}
  alias Palapa.Organizations

  schema "sections" do
    field(:title, :string)
    field(:position, :integer)
    timestamps()

    belongs_to(:document, Document)
    belongs_to(:last_author, Organizations.Member)
    has_many(:pages, Page)
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
