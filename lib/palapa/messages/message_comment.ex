defmodule Palapa.Messages.MessageComment do
  use Palapa.Schema
  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Messages.Message
  alias Palapa.Messages.MessageComment
  alias Palapa.Attachments.Attachment

  schema "messages_comments" do
    belongs_to(:organization, Organization)
    belongs_to(:message, Message)
    belongs_to(:creator, Member)
    has_many(:attachments, Attachment, on_replace: :nilify)
    field(:content, :string)
    field(:deleted_at, :utc_datetime)
    timestamps()
  end

  def changeset(%MessageComment{} = message_comment, attrs) do
    message_comment
    |> cast(attrs, [:content])
    |> validate_required(:content)
  end
end
