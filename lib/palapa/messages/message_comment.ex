defmodule Palapa.Messages.MessageComment do
  use Palapa.Schema
  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Messages.Message
  alias Palapa.Messages.MessageComment

  schema "messages_comments" do
    belongs_to(:organization, Organization)
    belongs_to(:message, Message)
    belongs_to(:creator, Member)
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
