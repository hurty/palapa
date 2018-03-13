defmodule Palapa.Announcements do
  use Palapa.Context
  alias Palapa.Announcements.Announcement
  alias Palapa.Organizations.Organization
  alias Palapa.Organizations.Member

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

  def published_to_everyone(queryable \\ Announcement) do
    queryable
    |> where(published_to_everyone: true)
  end

  def published_today(queryable \\ Announcement) do
    today =
      Timex.now()
      |> Timex.beginning_of_day()

    tomorrow =
      today
      |> Timex.shift(days: 1)

    queryable
    |> where([a], a.inserted_at >= ^today and a.inserted_at < ^tomorrow)
  end

  def published_yesterday(queryable \\ Announcement) do
    today =
      Timex.now()
      |> Timex.beginning_of_day()

    yesterday =
      today
      |> Timex.shift(days: -1)

    queryable
    |> where([a], a.inserted_at >= ^yesterday and a.inserted_at < ^today)
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
    |> put_teams(teams)
    |> Repo.insert()
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

  def change(%Announcement{} = announcement) do
    Announcement.changeset(announcement, %{})
  end
end
