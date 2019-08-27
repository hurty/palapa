defmodule Palapa.Accounts do
  use Palapa.Context

  alias Palapa.Accounts.Account

  # --- Authorizations ---

  defdelegate(authorize(action, user, params), to: Palapa.Users.Policy)

  # --- Actions ---

  def get!(account_id), do: Repo.get!(Account, account_id)

  def get_by(conditions), do: Repo.get_by(Account, conditions)

  def create(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def change_account(account) do
    Account.changeset(account, %{})
  end

  def update_account(account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  def change_password(account) do
    Account.password_changeset(account, %{})
  end

  def update_password(account, attrs) do
    Account.password_changeset(account, attrs)
    |> Repo.update()
  end

  def reset_password(account, attrs) do
    Account.password_reset_changeset(account, attrs)
    |> Repo.update()
  end

  def generate_password_reset_token(account) do
    token = Palapa.Access.generate_token()

    params = %{
      password_reset_hash: Palapa.Access.hash_string(token),
      password_reset_at: DateTime.utc_now()
    }

    account
    |> cast(params, [:password_reset_hash, :password_reset_at])
    |> Repo.update()
    |> case do
      {:ok, _} -> {:ok, token}
      other -> other
    end
  end

  def find_account_by_password_reset_token(token) do
    freshness_datetime = Timex.shift(DateTime.utc_now(), hours: -1)
    token_hash = Palapa.Access.hash_string(token)

    from(a in Account,
      where:
        a.password_reset_at > ^freshness_datetime and
          a.password_reset_hash == ^token_hash
    )
    |> Repo.one()
  end

  def delete(user) do
    Repo.delete(user)
  end

  def list_organizations(account) do
    account
    |> Ecto.assoc(:organizations)
    |> order_by(:name)
    |> Repo.all()
  end

  def main_organization(account) do
    account
    |> Ecto.assoc(:organizations)
    |> first()
    |> Repo.one()
  end

  def organization_for_account(account, organization_id) do
    account
    |> Ecto.assoc(:organizations)
    |> where(id: ^organization_id)
    |> preload(:subscription)
    |> Repo.one()
  end

  def member_for_organization(account, organization) do
    Palapa.Organizations.Member
    |> where(account_id: ^account.id, organization_id: ^organization.id)
    |> Repo.one()
  end
end
