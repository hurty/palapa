defmodule Palapa.Documents.Document do
  use Palapa.Schema

  alias Palapa.Organizations.{Organization, Member}
  alias Palapa.Teams.Team
  alias Palapa.Documents.{Section, Page, DocumentAccess}

  schema "documents" do
    field(:title, :string)
    field(:deleted_at, :utc_datetime)
    field(:public_token, :string)
    timestamps()

    belongs_to(:organization, Organization)
    belongs_to(:last_author, Member, on_replace: :nilify)
    belongs_to(:team, Team, on_replace: :nilify)
    has_many(:sections, Section)
    has_many(:pages, Page)
    has_many(:document_accesses, DocumentAccess)

    belongs_to(:deletion_author, Member, on_replace: :nilify)
  end

  @doc false
  def changeset(document \\ %__MODULE__{}, attrs) do
    document
    |> cast(attrs, [:title])
    |> validate_required([:title])
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
