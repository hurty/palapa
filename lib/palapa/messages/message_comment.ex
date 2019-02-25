defmodule Palapa.Messages.MessageComment do
  use Palapa.Schema
  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Messages.Message
  alias Palapa.Messages.MessageComment
  alias Palapa.Attachments.Attachment

  schema "message_comments" do
    field(:content, :string)
    timestamps()

    belongs_to(:organization, Organization)
    belongs_to(:message, Message)
    belongs_to(:creator, Member)

    many_to_many(:attachments, Attachment,
      join_through: "message_comments_attachments",
      on_replace: :delete
    )
  end

  def changeset(%MessageComment{} = message_comment, attrs) do
    message_comment
    |> cast(attrs, [:content])
    |> validate_required(:content)
  end
end
