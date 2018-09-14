defmodule Palapa.Attachments.Attachment do
  use Palapa.Schema

  alias Palapa.Organizations.{Organization}
  alias Palapa.Attachments.{Attachment}

  schema "attachments" do
    belongs_to(:organization, Organization)
    field(:filename, :string)
    field(:content_type, :string)
    field(:byte_size, :integer)
    timestamps()
    field(:deleted_at, :utc_datetime)

    belongs_to(:message, Palapa.Messages.Message)
    belongs_to(:message_comment, Palapa.Messages.MessageComment)
    belongs_to(:member_information, Palapa.Organizations.MemberInformation)
  end

  def changeset(%Attachment{} = attachment, attrs) do
    attachment
    |> cast(attrs, [:filename, :content_type])
  end
end
