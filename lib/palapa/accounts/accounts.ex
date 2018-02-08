defmodule Palapa.Accounts do
  import Ecto.Query, warn: false
  import Ecto.Changeset, warn: false
  alias Palapa.Repo
  alias Palapa.Accounts
  alias Palapa.Accounts.{User, Organization, Membership, Registration, Team, TeamUser}

  defdelegate(authorize(action, user, params), to: Palapa.Accounts.Policy)

  import EctoEnum
  defenum(RoleEnum, :role, [:owner, :admin, :member])

  # USERS

  @doc """
  Gets a user by its id and organization id.

  Similar to `get_user!/1` but also loads the organization and 
  the role into the user struct.

  This function should be used in the context of a http request 
  where we need to know what is the current role of the current user.
  This is used for authorization checks.

  Raises `Ecto.NoResultsError` if no user was found.
  """
  def get_user!(user_id, organization) do
    user =
      from(
        u in User,
        join: m in assoc(u, :memberships),
        preload: [memberships: m],
        where: m.user_id == ^user_id and m.organization_id == ^organization.id
      )
      |> Repo.one!()

    membership = Enum.at(user.memberships, 0)

    user
    |> Map.put(:membership, membership)
    |> Map.put(:organization, organization)
    |> Map.put(:role, membership.role)
  end

  @doc """
  Gets the first user matching the given conditions.

  Returns nil if no User is found.

  ## Example:

    Accounts.get_user_by(email: "pierre.hurtevent@gmail.com")
  """
  def get_user_by(conditions), do: Repo.get_by(User, conditions)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  # ORGANIZATIONS

  def list_organizations do
    Repo.all(Organization)
  end

  def get_organization!(id) do
    Repo.get!(Organization, id)
  end

  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  def change_organization(%Organization{} = organization) do
    Organization.changeset(organization, %{})
  end

  @doc """
  Lists all users from an organization
  """
  def list_organization_users(%Organization{} = organization) do
    organization
    |> Ecto.assoc(:users)
    |> order_by(:name)
    |> Repo.all()
  end

  def list_team_users(%Team{} = team) do
    team
    |> Ecto.assoc(:users)
    |> order_by(:name)
    |> Repo.all()
  end

  def list_user_organizations(%User{} = user) do
    user
    |> Ecto.assoc(:organizations)
    |> order_by(:name)
    |> Repo.all()
  end

  @doc """
  Gets the first Organization of user (in case he's part of many).
  This organization will be considered his main one.
  TODO: save the setting in DB later.
  """
  def get_user_main_organization!(%User{} = user) do
    Organization
    |> join(:inner, [o], m in Membership, o.id == m.organization_id and m.user_id == ^user.id)
    |> first
    |> Repo.one!()
  end

  def user_in_organization?(%User{} = user, %Organization{} = organization) do
    Membership
    |> where(user_id: ^user.id, organization_id: ^organization.id)
    |> Repo.exists?()
  end

  # MEMBERSHIPS

  def create_membership(attrs \\ %{}) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  # REGISTRATIONS

  @doc """
  Creates a new organization and a new user account in this organization.

  Accepts a struct as a parameter, with all these attributes:
    - name
    - email
    - password
    - organization_name
  """
  def create_registration(attrs \\ %{}) do
    changeset = Registration.changeset(%Registration{}, attrs)

    user_attrs = Map.take(changeset.changes, [:name, :email, :password])
    organization_attrs = %{name: Map.get(changeset.changes, :organization_name)}

    Ecto.Multi.new()
    |> Ecto.Multi.run(:registration, fn _ ->
      Registration.validate(changeset)
    end)
    |> Ecto.Multi.run(:user, fn _changes ->
      Accounts.create_user(user_attrs)
    end)
    |> Ecto.Multi.run(:organization, fn _changes ->
      Accounts.create_organization(organization_attrs)
    end)
    |> Ecto.Multi.run(:membership, fn changes ->
      Accounts.create_membership(%{
        organization_id: changes.organization.id,
        user_id: changes.user.id
      })
    end)
    |> Repo.transaction()
  end

  def change_registration(%Registration{} = registration) do
    Registration.changeset(registration, %{})
  end

  # TEAMS

  @doc """
  Returns the list of teams in an organization.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams(%Organization{} = organization) do
    query =
      from(
        t in Team,
        where: t.organization_id == ^organization.id,
        order_by: :name
      )

    Repo.all(query)
  end

  @doc """
  Returns the list of a user's teams within an organization.

  ## Examples

      iex> list_user_teams(organization, user)
      [%Team{}, ...]

  """
  def list_user_teams(%Organization{} = organization, %User{} = user) do
    Ecto.assoc(organization, :teams)
    |> Bodyguard.scope(user)
    |> order_by(:name)
    |> Repo.all()
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id), do: Repo.get!(Team, id)

  def create_team(%Organization{} = organization, attrs \\ %{}) do
    team_attrs = Map.merge(attrs, %{organization_id: organization.id})

    %Team{}
    |> Team.create_changeset(team_attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{source: %Team{}}

  """
  def change_team(%Team{} = team) do
    Team.changeset(team, %{})
  end

  def add_user_to_team(%User{} = user, %Team{} = team) do
    TeamUser.changeset(%TeamUser{}, %{user_id: user.id, team_id: team.id})
    |> increment_counter_cache(team, :users_count)
    |> Repo.insert()
    |> case do
      {:ok, team_user} ->
        {:ok, Repo.get(Team, team_user.team_id)}

      {_, details} ->
        {:error, details}
    end
  end

  def user_in_team?(%User{} = user, %Team{} = team) do
    TeamUser
    |> where(user_id: ^user.id, team_id: ^team.id)
    |> Repo.exists?()
  end

  defp increment_counter_cache(changeset, struct, counter_name, value \\ 1) do
    prepare_changes(changeset, fn prepared_changeset ->
      prepared_changeset.repo.increment(struct, counter_name, value)
      prepared_changeset
    end)
  end

  def remove_user_from_team(%User{} = user, %Team{} = team) do
    team_user_query =
      from(tu in TeamUser, where: tu.user_id == ^user.id and tu.team_id == ^team.id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:team_user, team_user_query)
    |> Ecto.Multi.run(:counter_cache_decrement, fn changes_so_far ->
      # Avoids having a negative counter by checking if the row has actually been deleted
      %{team_user: {deleted_entries_count, nil}} = changes_so_far

      if deleted_entries_count > 0 do
        Repo.decrement(team, :users_count)
      else
        {:ok, team}
      end
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        {:ok, Repo.reload(team)}

      {_, details} ->
        {:error, details}
    end
  end
end
