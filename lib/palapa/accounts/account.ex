defmodule Palapa.Accounts.Account do
  use Palapa.Schema

  alias Palapa.Accounts
  alias Palapa.Organizations

  schema "accounts" do
    field(:email, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    timestamps()

    has_many(:members, Organizations.Member)
    has_many(:organizations, through: [:members, :organization])
  end

  @doc false
  def changeset(%Accounts.Account{} = user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> put_password_hash
    |> validate_required([:email, :password_hash])
    |> unique_constraint(:email, name: "accounts_email_index")
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
