defmodule Palapa.Organizations do
  use Palapa.Context

  alias Organizations.{Organization, Member}

  defdelegate(authorize(action, user, params), to: Palapa.Organizations.Policy)

  import EctoEnum
  defenum(RoleEnum, :role, [:owner, :admin, :member])

  ### Scopes

  def with_member_name(queryable \\ Member, name_pattern) do
    if name_pattern do
      escaped_pattern = Repo.escape_like_pattern(name_pattern) <> "%"
      where(queryable, [q], ilike(q.name, ^escaped_pattern))
    else
      queryable
    end
  end

  ### Actions

  def list(queryable \\ Organization) do
    queryable
    |> Repo.all()
  end

  def get!(id) do
    Repo.get!(Organization, id)
  end

  def create(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Organization{} = organization) do
    Repo.delete(organization)
  end

  def change(%Organization{} = organization) do
    Organization.changeset(organization, %{})
  end

  def list_members(queryable \\ Organization, name_pattern \\ nil) do
    queryable
    |> Ecto.assoc(:members)
    |> with_member_name(name_pattern)
    |> preload(:account)
    |> Repo.all()
  end

  def list_members_by_ids(%Organization{} = organization, ids) when is_list(ids) do
    organization
    |> Ecto.assoc(:members)
    |> Access.scope_by_ids(ids)
    |> Repo.all()
  end

  def members_count(queryable \\ Organization) do
    queryable
    |> Ecto.assoc(:members)
    |> Repo.count()
  end

  def get_member!(%Organization{} = organization, member_id) do
    organization
    |> Ecto.assoc(:members)
    |> preload(:account)
    |> Repo.get!(member_id)
  end

  def get_member_with_account!(member_id) do
    Member
    |> join(:left, [m], o in assoc(m, :organization))
    |> join(:left, [m], a in assoc(m, :account))
    |> preload([_, o, _], organization: o)
    |> preload([..., a], account: a)
    |> Repo.get!(member_id)
  end

  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  def update_member(%Member{} = member, attrs) do
    member
    |> Member.update_profile_changeset(attrs)
    |> Repo.update()
  end

  def member_change(%Member{} = member) do
    Member.update_profile_changeset(member, %{})
  end
end
