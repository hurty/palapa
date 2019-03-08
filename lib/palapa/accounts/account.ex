defmodule Palapa.Accounts.Account do
  use Palapa.Schema
  use Arc.Ecto.Schema

  alias Palapa.Organizations

  schema "accounts" do
    field(:email, :string)
    field(:name, :string)
    field(:password_hash, :string)
    field(:password, :string, virtual: true)
    field(:current_password, :string, virtual: true)
    field(:timezone, :string)
    field(:avatar, Palapa.Avatar.Type)
    timestamps()

    has_many(:members, Organizations.Member)
    has_many(:organizations, through: [:members, :organization])
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:email, :name, :password, :timezone])
    |> put_uuid()
    |> put_password_hash
    |> cast_attachments(attrs, [:avatar])
    |> validate_required([:email, :name, :password_hash])
    |> validate_timezone()
    |> unique_constraint(:email, name: "accounts_email_index")
  end

  def password_changeset(account, attrs) do
    account
    |> cast(attrs, [:current_password, :password])
    |> validate_current_password()
    |> validate_length(:password, min: 8, max: 100)
    |> validate_confirmation(:password, message: "Password confirmation does not match")
    |> put_password_hash()
    |> validate_required([:password_hash])
  end

  def validate_timezone(changeset) do
    tz = get_field(changeset, :timezone)

    if !Tzdata.zone_exists?(tz) do
      add_error(changeset, :timezone, "Timezone is invalid.")
    else
      changeset
    end
  end

  def validate_current_password(changeset) do
    current_password = get_change(changeset, :current_password)
    current_password_hash = get_field(changeset, :password_hash)

    cond do
      is_nil(current_password) ->
        add_error(changeset, :current_password, "You must provide your current password")

      current_password && Comeonin.Bcrypt.checkpw(current_password, current_password_hash) ->
        changeset

      true ->
        add_error(changeset, :current_password, "The current password is not correct")
    end
  end

  def put_uuid(changeset) do
    if is_nil(get_field(changeset, :id)) do
      force_change(changeset, :id, Ecto.UUID.generate())
    else
      changeset
    end
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
