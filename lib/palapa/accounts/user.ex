defmodule Palapa.Accounts.User do
  use Ecto.Schema

  import Ecto.Changeset
  alias Palapa.Accounts.{User, Membership, Team, TeamUser}

  schema "users" do
    field(:email, :string)
    field(:name, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:title, :string)
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
    |> validate_required([:email, :name])
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
end
