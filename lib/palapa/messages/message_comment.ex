defmodule Palapa.Messages.MessageComment do
  use Palapa.Schema
  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Messages.Message
  alias Palapa.Messages.MessageComment
  alias Palapa.Attachments.Attachment
  alias Palapa.RichText

  @derive {Jason.Encoder, only: [:creator_id, :inserted_at, :content, :attachments]}

  schema "message_comments" do
    field(:content, RichText.Type)
    timestamps()

    belongs_to(:organization, Organization)
    belongs_to(:message, Message)
    belongs_to(:creator, Member)

    has_many(:attachments, Attachment, on_replace: :delete)
  end

  def changeset(%MessageComment{} = message_comment, attrs) do
    message_comment
    |> cast(attrs, [:content])
    |> RichText.Changeset.put_rich_text_attachments(:content, :attachments, :message_comment)
    |> validate_required(:content)
  end
end
