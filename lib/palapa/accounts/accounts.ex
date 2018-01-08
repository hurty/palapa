defmodule Palapa.Accounts do
  import Ecto.Query, warn: false
  alias Palapa.Repo
  alias Palapa.Accounts
  alias Palapa.Accounts.{User, Organization, Membership, Registration}


  # USERS

  def list_users do
    Repo.all(User)
  end

  def get_user!(id) do
    Repo.get!(User, id)
  end

  @doc """
  Gets a user by its email address.

  Returns nil if the User does not exist.
  """
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

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
  Gets the first Organization of user (in case he's part of many).
  This organization will be considered his main one.
  TODO: save the setting in DB later.
  """
  def get_user_main_organization!(%User{} = user) do
    Organization
    |> join(:inner, [o], m in Membership, o.id == m.organization_id and m.user_id == ^user.id)
    |> first
    |> Repo.one!
  end


  # MEMBERSHIPS

  def list_memberships do
    Repo.all(Membership)
  end

  def get_membership!(id), do: Repo.get!(Membership, id)

  def create_membership(attrs \\ %{}) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  def change_membership(%Membership{} = membership) do
    Membership.changeset(membership, %{})
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

    Ecto.Multi.new
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
      Accounts.create_membership(%{organization_id: changes.organization.id, user_id: changes.user.id})
    end)
    |> Repo.transaction
  end

  def change_registration(%Registration{} = registration) do
    Registration.changeset(registration, %{})
  end
end
