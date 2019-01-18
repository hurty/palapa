defmodule Palapa.Documents.DocumentAccess do
  use Palapa.Schema

  alias Palapa.Organizations.Member
  alias Palapa.Documents.Document

  schema "documents_accesses" do
    belongs_to(:document, Document)
    belongs_to(:member, Member)
    field(:last_access_at, :utc_datetime)
  end

  def changeset(document_access \\ %__MODULE__{}, attrs) do
    document_access
    |> cast(attrs, [:last_access_at])
    |> put_assoc(:document, attrs.document)
    |> put_assoc(:member, attrs.member)
    |> unique_constraint(:member, name: "documents_accesses_document_id_member_id_index")
  end
end
