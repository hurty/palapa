defmodule Palapa.Documents.Section do
  use Palapa.Schema

  alias Palapa.Documents.{Document, Page}
  alias Palapa.Organizations

  schema "document_sections" do
    field(:title, :string)
    timestamps()

    belongs_to(:document, Document)
    belongs_to(:organization, Organizations.Organization)
    belongs_to(:last_author, Organizations.Member)
    has_many(:pages, Page)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
