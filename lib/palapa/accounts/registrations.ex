defmodule Palapa.Accounts.Registrations do
  alias Palapa.Repo
  alias Palapa.Accounts.Registration
  alias Palapa.Accounts
  alias Palapa.Organizations
  alias Palapa.Billing
  alias Palapa.Events.Event

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
    |> Ecto.Multi.run(:registration, fn _repo, _ ->
      Registration.validate(changeset)
    end)
    |> Ecto.Multi.run(:account, fn _repo, _changes ->
      Accounts.create(account_attrs)
    end)
    |> Ecto.Multi.run(:organization, fn _repo, _changes ->
      Organizations.create(organization_attrs)
    end)
    |> Ecto.Multi.run(:subscription, fn _repo, %{organization: organization} ->
      Billing.create_subscription(organization)
    end)
    |> Ecto.Multi.run(:member, fn _repo, changes ->
      Organizations.create_member(%{
        organization_id: changes.organization.id,
        account_id: changes.account.id,
        role: :owner
      })
    end)
    |> Ecto.Multi.insert(:event, fn %{organization: organization, member: member} ->
      %Event{
        action: :new_organization,
        organization: organization,
        author: member
      }
    end)
    |> Repo.transaction()
  end

  def change(%Registration{} = registration) do
    Registration.changeset(registration, %{})
  end
end
