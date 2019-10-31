defmodule Palapa.Attachments.Attachment do
  use Palapa.Schema

  alias Palapa.Organizations.{Organization}
  alias Palapa.Attachments.{Attachment}

  schema "attachments" do
    belongs_to(:organization, Organization)
    field(:filename, :string)
    field(:content_type, :string)
    field(:byte_size, :integer)
    field(:checksum, :string)
    timestamps()
    field(:deleted_at, :utc_datetime)
    belongs_to(:creator, Palapa.Organizations.Member)
  end

  def changeset(%Attachment{} = attachment, attrs) do
    attachment
    |> cast(attrs, [:filename, :content_type, :byte_size, :checksum])
  end
end
