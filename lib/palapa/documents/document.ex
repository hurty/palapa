defmodule Palapa.Documents.Document do
  use Palapa.Schema

  alias Palapa.Organizations
  alias Palapa.Documents

  schema "documents" do
    field(:title, :string)
    timestamps()

    belongs_to(:organization, Organizations.Organization)
    belongs_to(:last_author, Organizations.Member)
    has_many(:sections, Documents.Section)
    has_many(:pages, through: [:sections, :pages])
    belongs_to(:first_page, Documents.Page)
  end

  @doc false
  def changeset(document, attrs) do
    document
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
