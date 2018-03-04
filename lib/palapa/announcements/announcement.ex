defmodule Palapa.Announcements.Announcement do
  use Palapa.Schema
  alias Palapa.Organizations
  alias Palapa.Announcements.Announcement

  schema "announcements" do
    belongs_to(:organization, Organizations.Organization)
    belongs_to(:creator, Organizations.Member)
    timestamps()
    field(:title, :string)
    field(:content, :string)
  end

  def changeset(%Announcement{} = announcement, attrs) do
    announcement
    |> cast(attrs, [:title, :content])
  end
end
