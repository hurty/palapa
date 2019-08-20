defmodule Palapa.Documents.Page do
  use Palapa.Schema

  alias Palapa.Documents.{Document, Section, Page, Suggestion}
  alias Palapa.RichText
  alias Palapa.Organizations.{Member}
  alias Palapa.Searches.Search
  alias Palapa.Attachments.Attachment
  import Ecto.Query

  schema "pages" do
    field(:title, :string)
    field(:position, :integer)
    field(:content, RichText.Type)
    timestamps()

    belongs_to(:document, Document)
    belongs_to(:section, Section)
    belongs_to(:last_author, Member)
    has_one(:team, through: [:document, :team])
    has_many(:searches, Search)

    field(:deleted_at, :utc_datetime)
    belongs_to(:deletion_author, Member, on_replace: :update)

    has_many(:suggestions, Suggestion)

    many_to_many(:attachments, Attachment,
      join_through: "pages_attachments",
      on_replace: :delete
    )
  end

  def with_document(query), do: preload(query, document: [:team, [sections: :pages]])
  def with_section(query), do: preload(query, :section)
  def with_last_author(query), do: preload(query, last_author: :account)
  def with_attachments(query), do: preload(query, :attachments)
  def without_content(query), do: select(query, ^(Page.__schema__(:fields) -- [:content]))

  def changeset(page, attrs) do
    page
    |> cast(attrs, [:title, :content, :position, :section_id])
    |> RichText.Changeset.put_rich_text_attachments(:content, :attachments)
    |> validate_required([:title])
  end
end
