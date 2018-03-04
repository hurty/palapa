defmodule Palapa.Announcements do
  use Palapa.Context
  alias Palapa.Announcements.Announcement
  alias Palapa.Organizations.Organization

  defdelegate(authorize(action, member, params), to: Palapa.Announcements.Policy)

  def list(queryable \\ Announcement, %Organization{} = organization) do
    queryable
    |> Access.scope(organization)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def create(organization, creator, attrs) do
    Announcement.changeset(%Announcement{}, attrs)
    |> Ecto.Changeset.put_change(:organization_id, organization.id)
    |> Ecto.Changeset.put_change(:creator_id, creator.id)
    |> Repo.insert()
  end

  def change(%Announcement{} = announcement) do
    announcement
    |> Announcement.changeset(%{})
  end
end
