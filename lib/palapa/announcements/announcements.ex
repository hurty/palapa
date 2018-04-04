defmodule Palapa.Announcements do
  use Palapa.Context
  alias Palapa.Announcements.Announcement
  alias Palapa.Organizations.Organization
  alias Palapa.Organizations.Member
  alias Palapa.Teams.Team

  # --- Authorizations

  defdelegate(authorize(action, member, params), to: Palapa.Announcements.Policy)

  # --- Scopes

  def visible_to(queryable \\ Announcement, %Member{} = member) do
    queryable
    |> where_organization(member.organization)
    |> published_to_everyone
    |> or_where([q], q.id in ^announcements_ids_visible_to(member))
  end

  def where_organization(queryable \\ Announcement, %Organization{} = organization) do
    queryable
    |> where(organization_id: ^organization.id)
  end

  def published_to(queryable \\ Announcement, %Team{} = team) do
    queryable
    |> where([q], q.id in ^announcements_ids_where_team(team))
  end

  def published_to_everyone(queryable \\ Announcement) do
    queryable
    |> where(published_to_everyone: true)
  end

  def published_between(queryable \\ Announcement, time_start, time_end) do
    queryable
    |> where([a], a.inserted_at >= ^time_start and a.inserted_at < ^time_end)
  end

  def published_before(queryable \\ Announcement, time) do
    queryable
    |> where([a], a.inserted_at < ^time)
  end

  defp announcements_ids_where_team(%Team{} = team) do
    Ecto.assoc(team, :announcements)
    |> select([q], q.id)
    |> Repo.all()
  end

  defp announcements_ids_visible_to(%Member{} = member) do
    teams = Ecto.assoc(member, :teams)

    from(
      announcements in Announcement,
      distinct: true,
      join: announcement_teams in assoc(announcements, :teams),
      join: member_teams in subquery(teams),
      on: announcement_teams.id == member_teams.id,
      select: announcements.id
    )
    |> Repo.all()
  end

  # --- Actions

  def list(queryable \\ Announcement) do
    queryable
    |> prepare_list()
    |> Repo.all()
  end

  def paginate(queryable \\ Announcement, page \\ 1) do
    queryable
    |> prepare_list
    |> Repo.paginate(page: page, page_size: 10)
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
    |> put_teams(teams)
    |> Repo.insert()
  end

  def change(%Announcement{} = announcement) do
    Announcement.changeset(announcement, %{})
  end

  defp prepare_list(queryable) do
    queryable
    |> order_by(desc: :inserted_at)
    |> preload([:creator, :teams])
  end

  defp put_teams(changeset, teams) do
    if teams && Enum.any?(teams) do
      changeset
      |> put_change(:published_to_everyone, false)
      |> put_assoc(:teams, teams)
    else
      changeset
    end
  end
end
