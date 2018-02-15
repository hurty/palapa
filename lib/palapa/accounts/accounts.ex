defmodule Palapa.Accounts do
  use Palapa.Context

  alias Palapa.Accounts.Account
  alias Palapa.Organizations.Organization

  defdelegate(authorize(action, user, params), to: Palapa.Users.Policy)

  def get!(account_id), do: Repo.get!(Account, account_id)

  def get_by(conditions), do: Repo.get_by(Account, conditions)

  def create(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Account{} = user, attrs) do
    user
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def delete(%Account{} = user) do
    Repo.delete(user)
  end

  def change(%Account{} = user) do
    Account.changeset(user, %{})
  end

  def list_organizations(%Account{} = account) do
    account
    |> Ecto.assoc(:organizations)
    |> order_by(:name)
    |> Repo.all()
  end

  def main_organization(%Account{} = account) do
    account
    |> Ecto.assoc(:organizations)
    |> first()
    |> Repo.one()
  end

  def member_for_organization(%Account{} = account, %Organization{} = organization) do
    Palapa.Organizations.Member
    |> where(account_id: ^account.id, organization_id: ^organization.id)
    |> Repo.one()
  end
end
