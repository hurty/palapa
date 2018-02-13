defmodule Palapa.Accounts.User do
  use Palapa.Schema

  alias Palapa.Accounts.{User, Membership, RoleEnum}
  alias Palapa.Teams.{Team, TeamUser}

  schema "users" do
    field(:email, :string)
    field(:name, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:title, :string)
    field(:role, RoleEnum, virtual: true)
    timestamps()

    has_many(:memberships, Membership)
    has_many(:organizations, through: [:memberships, :organization])
    many_to_many(:teams, Team, join_through: TeamUser)
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :name, :password, :title])
    |> put_password_hash
    |> validate_required([:email, :name, :password_hash])
    |> unique_constraint(:email)
  end

  def put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end

  def put_role(user, role) do
    Ecto.Changeset.change(user, role: role)
    |> Palapa.Repo.update()
    |> case do
      {:ok, user} -> user
      _ -> {:error, "cannot put role into user struct"}
    end
  end
end
