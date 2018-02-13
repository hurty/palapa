defmodule Palapa.Users do
  import Ecto.Query
  alias Palapa.Repo
  alias Palapa.Users.User

  defdelegate(authorize(action, user, params), to: Palapa.Users.Policy)

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
  def get!(user_id, organization) do
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

  def get_by(conditions), do: Repo.get_by(User, conditions)

  def create(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete(%User{} = user) do
    Repo.delete(user)
  end

  def change(%User{} = user) do
    User.changeset(user, %{})
  end
end
