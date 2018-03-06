defmodule Palapa.Announcements do
  use Palapa.Context
  alias Palapa.Announcements.Announcement
  alias Palapa.Organizations.Organization
  alias Palapa.Organizations.Member

  # --- Authorizations

  defdelegate(authorize(action, member, params), to: Palapa.Announcements.Policy)

  # --- Scopes

  def where_organization(queryable \\ Announcement, %Organization{} = organization) do
    queryable
    |> where(organization_id: ^organization.id)
  end

  def visible_to(queryable \\ Announcement, %Member{} = member) do
    teams = Ecto.assoc(member, :teams)

    from(
      announcements in queryable,
      distinct: true,
      join: announcement_teams in assoc(announcements, :teams),
      join: member_teams in subquery(teams),
      on: announcement_teams.id == member_teams.id
    )
  end

  # --- Actions
  def list(queryable \\ Announcement) do
    queryable
    |> order_by(desc: :inserted_at)
    |> preload(:creator)
    |> Repo.all()
  end

  def get!(queryable \\ Announcement, id) do
    queryable
    |> preload(:creator)
    |> Repo.get!(id)
  end

  def create(%Organizations.Member{} = creator, attrs, teams) do
    %Announcement{}
    |> Announcement.changeset(attrs)
    |> put_change(:organization, creator.organization)
    |> put_change(:creator, creator)
    |> put_assoc(:teams, teams)
    |> Repo.insert()
  end

  def change(%Announcement{} = announcement) do
    Announcement.changeset(announcement, %{})
  end
end
