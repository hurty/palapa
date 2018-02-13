defmodule Palapa.Organizations do
  import Ecto.Query
  alias Palapa.Repo
  alias Palapa.Users.User
  alias Palapa.Organizations.{Organization, Membership}

  defdelegate(authorize(action, user, params), to: Palapa.Organizations.Policy)

  import EctoEnum
  defenum(RoleEnum, :role, [:owner, :admin, :member])

  # ORGANIZATIONS

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

  def list_users(%Organization{} = organization) do
    organization
    |> Ecto.assoc(:users)
    |> order_by(:name)
    |> Repo.all()
  end

  def list_for_user(%User{} = user) do
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

  def create_membership(attrs \\ %{}) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  def member?(%Organization{} = organization, %User{} = user) do
    Membership
    |> where(user_id: ^user.id, organization_id: ^organization.id)
    |> Repo.exists?()
  end
end
