defmodule Palapa.Documents.Page do
  use Palapa.Schema

  alias Palapa.Documents.{Document, Section, RichText}
  alias Palapa.Organizations.{Member}

  import Ecto.Query

  schema "pages" do
    field(:title, :string)
    field(:position, :integer)
    field(:body, :string, virtual: true, default: nil)
    timestamps()

    belongs_to(:document, Document)
    belongs_to(:section, Section)
    belongs_to(:last_author, Member)
    has_one(:rich_text, RichText, on_replace: :delete)
  end

  def changeset(document, attrs) do
    document
    |> cast(attrs, [:title, :body])
    |> put_body
    |> validate_required([:title])
  end

  def put_body(changeset) do
    if(body = get_change(changeset, :body)) do
      changeset
      |> put_assoc(:rich_text, %{body: body})
    else
      changeset
    end
  end

  def with_last_author(query), do: preload(query, last_author: :account)
  def with_rich_text(query), do: preload(query, :rich_text)
end
