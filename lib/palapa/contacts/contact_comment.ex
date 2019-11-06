defmodule Palapa.Contacts.ContactComment do
  use Palapa.Schema

  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Contacts.Contact
  alias Palapa.RichText
  alias Palapa.Attachments.Attachment

  schema "contact_comments" do
    timestamps()
    belongs_to(:organization, Organization)
    belongs_to(:contact, Contact)
    belongs_to(:author, Member)
    field(:content, RichText.Type)

    has_many(:attachments, Attachment, on_replace: :delete)
  end

  def changeset(contact_comment, attrs \\ %{}) do
    contact_comment
    |> cast(attrs, [:content])
    |> RichText.Changeset.put_rich_text_attachments(:content, :attachments, :contact_comment)
    |> validate_required(:content)
  end
end
