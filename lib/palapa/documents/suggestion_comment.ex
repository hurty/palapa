defmodule Palapa.Documents.SuggestionComment do
  use Palapa.Schema

  alias Palapa.Repo
  alias Palapa.Documents.{Suggestion}
  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Attachments.Attachment
  alias Palapa.RichText

  schema "document_suggestion_comments" do
    field(:content, RichText.Type)
    timestamps()

    belongs_to(:organization, Organization)
    belongs_to(:suggestion, Suggestion)
    has_one(:document, through: [:suggestion, :document])
    belongs_to(:author, Member)

    has_many(:attachments, Attachment,
      on_replace: :delete,
      foreign_key: :document_suggestion_comment_id
    )
  end

  def changeset(comment, attrs) do
    comment
    |> Repo.preload(:attachments)
    |> cast(attrs, [:content])
    |> RichText.Changeset.put_rich_text_attachments(
      :content,
      :attachments,
      :document_suggestion_comment
    )
    |> validate_required([:content])
  end
end
