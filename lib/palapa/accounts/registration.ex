defmodule Palapa.Accounts.Registration do
  use Palapa.Schema

  embedded_schema do
    field(:name)
    field(:organization_name)
    field(:email)
    field(:password)
    field(:timezone)
  end

  def changeset(%__MODULE__{} = registration, params) do
    registration
    |> cast(params, [:name, :organization_name, :email, :password, :timezone])
    |> validate_required([:name, :organization_name, :email, :password])
    |> validate_length(:password, min: 8, max: 100)
    |> validate_timezone
    |> update_change(:name, &String.trim(&1))
    |> update_change(:email, &String.trim(&1))
    |> update_change(:organization_name, &String.trim(&1))
  end

  # We don't want to stop the whole registration process if the timezone is not found/valid.
  def validate_timezone(changeset) do
    tz = get_field(changeset, :timezone)

    if Tzdata.zone_exists?(tz) do
      changeset
    else
      put_change(changeset, :timezone, "UTC")
    end
  end

  def validate(changeset) do
    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end
end
