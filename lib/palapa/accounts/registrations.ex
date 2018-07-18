defmodule Palapa.Accounts.Registrations do
  alias Palapa.Repo
  alias Palapa.Accounts.Registration
  alias Palapa.Accounts
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
    account_attrs = Map.take(changeset.changes, [:email, :name, :password, :timezone])

    organization_attrs = %{
      name: Map.get(changeset.changes, :organization_name),
      default_timezone: Map.get(changeset.changes, :timezone)
    }

    Ecto.Multi.new()
    |> Ecto.Multi.run(:registration, fn _ ->
      Registration.validate(changeset)
    end)
    |> Ecto.Multi.run(:account, fn _changes ->
      Accounts.create(account_attrs)
    end)
    |> Ecto.Multi.run(:organization, fn _changes ->
      Organizations.create(organization_attrs)
    end)
    |> Ecto.Multi.run(:member, fn changes ->
      Organizations.create_member(%{
        organization_id: changes.organization.id,
        account_id: changes.account.id,
        role: :owner
      })
    end)
    |> Repo.transaction()
  end

  def change(%Registration{} = registration) do
    Registration.changeset(registration, %{})
  end
end
