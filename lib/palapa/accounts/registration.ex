defmodule Palapa.Accounts.Registration do
  use Palapa.Schema

  embedded_schema do
    field(:name)
    field(:organization_name)
    field(:email)
    field(:password)
  end

  def changeset(%__MODULE__{} = registration, params) do
    registration
    |> cast(params, [:name, :organization_name, :email, :password])
    |> validate_required([:name, :organization_name, :email, :password])
    |> validate_length(:password, min: 8, max: 100)
    |> update_change(:name, &String.trim(&1))
    |> update_change(:email, &String.trim(&1))
    |> update_change(:organization_name, &String.trim(&1))
  end

  def validate(changeset) do
    if changeset.valid? do
      {:ok, apply_changes(changeset)}
    else
      {:error, changeset}
    end
  end
end
