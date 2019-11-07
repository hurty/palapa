defmodule Palapa.Attachments.Attachment do
  use Palapa.Schema

  alias Palapa.Organizations.{Organization}
  alias Palapa.Attachments.{Attachment, AttachableTypeEnum}

  schema "attachments" do
    belongs_to(:organization, Organization)
    field(:filename, :string)
    field(:content_type, :string)
    field(:byte_size, :integer)
    field(:checksum, :string)
    timestamps()
    field(:deleted_at, :utc_datetime)
    belongs_to(:creator, Palapa.Organizations.Member)

    field(:attachable_type, AttachableTypeEnum)
    belongs_to(:personal_information, Palapa.Organizations.PersonalInformation)
    belongs_to(:message, Palapa.Messages.Message)
    belongs_to(:message_comment, Palapa.Messages.MessageComment)
    belongs_to(:page, Palapa.Documents.Page)
    belongs_to(:document_suggestion, Palapa.Documents.Suggestion)
    belongs_to(:document_suggestion_comment, Palapa.Documents.SuggestionComment)
    belongs_to(:contact_comment, Palapa.Contacts.ContactComment)
  end

  def changeset(%Attachment{} = attachment, attrs) do
    attachment
    |> cast(attrs, [:filename, :content_type, :byte_size, :checksum, :attachable_type])
  end
end
