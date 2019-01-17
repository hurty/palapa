defmodule Palapa.Documents.Page do
  use Palapa.Schema

  alias Palapa.Documents.{Document, Section, Page}
  alias Palapa.Organizations.{Member}

  import Ecto.Query

  schema "pages" do
    field(:title, :string)
    field(:position, :integer)
    field(:body, :string)
    field(:deleted_at, :utc_datetime)
    timestamps()

    belongs_to(:document, Document)
    belongs_to(:section, Section)
    belongs_to(:last_author, Member)
    has_many(:teams, through: [:document, :teams])
  end

  def changeset(page, attrs) do
    page
    |> cast(attrs, [:title, :body, :position, :section_id])
    |> validate_required([:title])
  end

  def with_document(query), do: preload(query, :document)
  def with_last_author(query), do: preload(query, last_author: :account)
  def without_body(query), do: select(query, ^(Page.__schema__(:fields) -- [:body]))
end
