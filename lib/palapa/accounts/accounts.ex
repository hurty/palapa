defmodule Palapa.Accounts do
  import Ecto.Query
  alias Palapa.Repo
  alias Palapa.Accounts
  alias Palapa.Accounts.{User, Organization, Membership, Registration}

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
end
