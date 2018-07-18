defmodule Palapa.Teams do
  use Palapa.Context

  alias Palapa.Teams.{Team, TeamMember}
  alias Palapa.Organizations.{Organization, Member}

  # --- Authorization ---

  defdelegate(authorize(action, member, params), to: Palapa.Teams.Policy)

  # --- Scopes ---

  def visible_to(member) do
    Ecto.assoc(member, :teams)
  end

  def where_organization(queryable \\ Team, organization) do
    if %Organization{} = organization do
      queryable
      |> where(organization_id: ^organization.id)
    else
      queryable
      |> where(organization_id: ^organization)
    end
  end

  def where_organization_id(queryable \\ Team, organization_id) do
    queryable
    |> where(organization_id: ^organization_id)
  end

  def where_ids(queryable \\ Team, ids) when is_list(ids) do
    queryable
    |> where([t], t.id in ^ids)
  end

  # --- Actions ---

  def get!(queryable \\ Team, id) do
    queryable
    |> preload(:members)
    |> Repo.get!(id)
  end

  def list(queryable \\ Team) do
    queryable
    |> order_by(:name)
    |> Repo.all()
  end

  def list_members(%Team{} = team) do
    team
    |> Ecto.assoc(:members)
    |> preload(:account)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def list_for_member(%Member{} = member) do
    Ecto.assoc(member, :teams)
    |> list()
  end

  def organization_has_teams?(%Organization{} = organization) do
    where_organization(organization)
    |> Repo.exists?()
  end

  def member_has_teams?(%Member{} = member) do
    member
    |> Ecto.assoc(:teams)
    |> Repo.exists?()
  end

  def create(%Organization{} = organization, attrs \\ %{}) do
    team_members = secure_members_list(organization, attrs)

    %Team{organization_id: organization.id}
    |> Team.create_changeset(attrs)
    |> put_assoc(:members, team_members)
    |> Repo.insert()
  end

  def update(%Team{} = team, attrs) do
    team = Repo.preload(team, [:organization, :members])
    team_members = secure_members_list(team.organization, attrs)

    team
    |> Team.changeset(attrs)
    |> put_assoc(:members, team_members)
    |> Repo.update()
  end

  defp secure_members_list(%Organization{} = organization, attrs) do
    if is_list(attrs["members"]) do
      Organizations.list_members_by_ids(organization, attrs["members"])
    else
      []
    end
  end

  def delete(%Team{} = team) do
    Repo.delete(team)
  end

  def change(%Team{} = team) do
    Repo.preload(team, :members)
    |> Team.changeset(%{})
  end

  def add_member(%Team{} = team, %Member{} = member) do
    TeamMember.changeset(%TeamMember{}, %{member_id: member.id, team_id: team.id})
    |> Repo.insert()
    |> case do
      {:ok, team_member} ->
        {:ok, Repo.get(Team, team_member.team_id)}

      {_, details} ->
        {:error, details}
    end
  end

  def remove_member(%Team{} = team, %Member{} = member) do
    team_member_query =
      from(tu in TeamMember, where: tu.member_id == ^member.id and tu.team_id == ^team.id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:team_member, team_member_query)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        {:ok, Repo.reload(team)}

      {_, details} ->
        {:error, details}
    end
  end

  def member?(%Team{} = team, %Member{} = member) do
    TeamMember
    |> where(member_id: ^member.id, team_id: ^team.id)
    |> Repo.exists?()
  end

  def update_all_teams_for_member(%Member{} = member, teams) when is_list(teams) do
    member
    |> Repo.preload(:teams)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:teams, teams)
    |> Repo.update()
  end
end
