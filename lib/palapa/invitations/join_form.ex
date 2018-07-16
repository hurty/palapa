defmodule Palapa.Invitations.JoinForm do
  use Palapa.Schema

  embedded_schema do
    field(:name)
    field(:title)
    field(:password)
    field(:timezone)
  end

  def changeset(%__MODULE__{} = registration, params) do
    registration
    |> cast(params, [:name, :title, :password, :timezone])
    |> validate_required([:name, :password])
    |> validate_length(:password, min: 8, max: 100)
    |> validate_or_nilify_timezone
    |> update_change(:name, &String.trim(&1))
    |> update_change(:title, &String.trim(&1))
  end

  # We don't want to stop the whole join process if the timezone is not found/valid.
  def validate_or_nilify_timezone(changeset) do
    tz = get_change(changeset, :timezone)

    if Tzdata.zone_exists?(tz) do
      changeset
    else
      put_change(changeset, :timezone, nil)
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
