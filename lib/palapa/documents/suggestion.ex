defmodule Palapa.Documents.Suggestion do
  use Palapa.Schema

  alias Palapa.Repo
  alias Palapa.Documents.{Page, SuggestionComment}
  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Attachments.Attachment
  alias Palapa.RichText

  schema "document_suggestions" do
    field(:content, RichText.Type)
    field(:closed_at, :utc_datetime)
    timestamps()

    belongs_to(:organization, Organization)
    belongs_to(:page, Page)
    has_one(:document, through: [:page, :document])
    belongs_to(:author, Member)
    has_many(:suggestion_comments, SuggestionComment)
    belongs_to(:closure_author, Member)
    has_many(:attachments, Attachment, on_replace: :delete, foreign_key: :document_suggestion_id)
  end

  def changeset(suggestion, attrs) do
    suggestion
    |> Repo.preload(:attachments)
    |> cast(attrs, [:content])
    |> RichText.Changeset.put_rich_text_attachments(:content, :attachments, :document_suggestion)
    |> validate_required([:content])
  end
end
