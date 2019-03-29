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
    belongs_to(:author, Member)

    many_to_many(:attachments, Attachment,
      join_through: "document_suggestion_comments_attachments",
      join_keys: [document_suggestion_comment_id: :id, attachment_id: :id],
      on_replace: :delete
    )
  end

  def changeset(comment, attrs) do
    comment
    |> Repo.preload(:attachments)
    |> cast(attrs, [:content])
    |> RichText.Changeset.put_rich_text_attachments(:content, :attachments)
    |> validate_required([:content])
  end
end
