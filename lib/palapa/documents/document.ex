defmodule Palapa.Documents.Document do
  use Palapa.Schema

  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Teams.Team
  alias Palapa.Documents.{DocumentTypeEnum, Section, Page, DocumentAccess}
  alias Palapa.Attachments.Attachment

  schema "documents" do
    field(:type, DocumentTypeEnum)
    field(:title, :string)
    field(:link, :string)
    field(:deleted_at, :utc_datetime)
    field(:public_token, :string)
    timestamps()

    has_one(:attachment, Attachment, on_replace: :delete)
    belongs_to(:organization, Organization)
    belongs_to(:last_author, Member, on_replace: :update)
    belongs_to(:team, Team, on_replace: :update)
    has_many(:sections, Section)
    has_many(:pages, Page)
    has_many(:document_accesses, DocumentAccess)

    belongs_to(:deletion_author, Member, on_replace: :update)
  end

  def changeset(document, attrs) do
    document
    |> cast(attrs, [:type, :title, :link])
    |> validate_required([:type, :title])
    |> validate_specific_type()
  end

  def validate_specific_type(changeset) do
    type = get_field(changeset, :type)

    case type do
      :attachment ->
        changeset
        |> validate_required(:attachment)
        |> cast_assoc(:attachment, with: &document_attachment_changeset/2)

      :link ->
        changeset |> validate_required(:link)

      _ ->
        changeset
    end
  end

  defp document_attachment_changeset(attachment, attrs) do
    Attachment.changeset(attachment, attrs)
    |> put_change(:attachable_type, :document)
  end

  def delete_changeset(%__MODULE__{} = document, %Member{} = deletion_author) do
    attrs = %{
      deleted_at: DateTime.utc_now(),
      deletion_author_id: deletion_author.id
    }

    # cast() will suppress microseconds for deleted_at
    document
    |> cast(attrs, [:deleted_at, :deletion_author_id])
  end

  def restore_changeset(%__MODULE__{} = document) do
    document
    |> change(%{deleted_at: nil, deletion_author_id: nil})
  end
end
