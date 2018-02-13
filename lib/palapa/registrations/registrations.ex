defmodule Palapa.Registrations do
  alias Palapa.Repo
  alias Palapa.Registrations.Registration
  alias Palapa.Users
  alias Palapa.Organizations

  @doc """
  Creates a new organization and a new user account in this organization.

  Accepts a struct as a parameter, with all these attributes:
    - name
    - email
    - password
    - organization_name
  """
  def create(attrs \\ %{}) do
    changeset = Registration.changeset(%Registration{}, attrs)

    user_attrs = Map.take(changeset.changes, [:name, :email, :password])
    organization_attrs = %{name: Map.get(changeset.changes, :organization_name)}

    Ecto.Multi.new()
    |> Ecto.Multi.run(:registration, fn _ ->
      Registration.validate(changeset)
    end)
    |> Ecto.Multi.run(:user, fn _changes ->
      Users.create(user_attrs)
    end)
    |> Ecto.Multi.run(:organization, fn _changes ->
      Organizations.create(organization_attrs)
    end)
    |> Ecto.Multi.run(:membership, fn changes ->
      Organizations.create_membership(%{
        organization_id: changes.organization.id,
        user_id: changes.user.id
      })
    end)
    |> Repo.transaction()
  end

  def change(%Registration{} = registration) do
    Registration.changeset(registration, %{})
  end
end
