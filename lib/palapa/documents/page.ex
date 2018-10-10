defmodule Palapa.Documents.Page do
  use Palapa.Schema

  alias Palapa.Documents
  alias Palapa.Organizations

  schema "document_pages" do
    field(:title, :string)
    field(:position, :integer)
    timestamps()

    belongs_to(:document, Documents.Document)
    belongs_to(:section, Documents.Section)
    belongs_to(:last_author, Organizations.Member)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
