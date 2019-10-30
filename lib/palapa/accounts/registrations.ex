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
      default_timezone: Map.get(changeset.changes, :timezone),
      allow_trial: true
    }

    Ecto.Multi.new()
    |> Ecto.Multi.run(:account_already_exists, fn _repo, _ ->
      email = attrs["email"]

      if Accounts.exists?(email) do
        {:error, email}
      else
        {:ok, nil}
      end
    end)
    |> Ecto.Multi.run(:registration, fn _repo, _ ->
      Registration.validate(changeset)
    end)
    |> Ecto.Multi.run(:account, fn _repo, _changes ->
      Accounts.create(account_attrs)
    end)
    |> Ecto.Multi.run(:organization_membership, fn _repo, %{account: account} ->
      Organizations.create(organization_attrs, account)
    end)
    |> Ecto.Multi.run(:daily_email, fn _, %{account: account} ->
      Accounts.schedule_daily_email(account)
    end)
    |> Repo.transaction()
  end

  def change(%Registration{} = registration) do
    Registration.changeset(registration, %{})
  end
end
