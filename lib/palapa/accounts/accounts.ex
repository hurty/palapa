defmodule Palapa.Accounts do
  use Palapa.Context
  use Palapa.SoftDelete

  alias Palapa.Accounts.Account

  # --- Scopes ---
  def accounts_with_daily_recap_subscription() do
    Account
    |> active()
    |> where(send_daily_recap: true)
  end

  # --- Actions ---

  def get(account_id), do: Repo.get(Account, account_id)
  def get!(account_id), do: Repo.get!(Account, account_id)

  def get_by(queryable \\ Account, conditions), do: Repo.get_by(queryable, conditions)

  def exists?(email) when is_binary(email) do
    Account
    |> where(email: ^email)
    |> Repo.exists?()
  end

  def exists?(email) when is_nil(email), do: false

  def create(attrs \\ %{}) do
    Account.changeset(%Account{}, attrs)
    |> Repo.insert()
  end

  def change_account(account) do
    Account.changeset(account, %{})
  end

  def update_account(account, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Account.changeset(account, attrs))
    |> Repo.transaction()
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

  def delete(account) do
    Multi.new()
    |> Multi.run(:account, fn _repo, _ -> soft_delete(account) end)
    |> Multi.run(:anonymized_account, fn _repo, %{account: account} -> anonymize(account) end)
    |> Multi.run(:delete_organizations, fn _repo, %{account: account} ->
      Organizations.delete_organizations_with_only_owner(account)
    end)
    |> Oban.insert(:delete_avatar, Accounts.Workers.DeleteAvatar.new(%{account_id: account.id}))
    |> Repo.transaction()
    |> case do
      {:ok, result} ->
        {:ok, result.anonymized_account}

      {:error, _, changeset, _changes} ->
        {:error, changeset}
    end
  end

  defp anonymize(account) do
    account
    |> change(%{name: initials(account.name), email: "#{account.id}@deleted"})
    |> Repo.update()
  end

  def initials(name) do
    name
    |> String.split(~r/\s+/)
    |> Enum.map(fn word -> String.at(word, 0) end)
    |> Enum.join()
    |> String.upcase()
  end

  def list_organizations(account) do
    account
    |> Ecto.assoc(:organizations)
    |> order_by(:name)
    |> Repo.all()
  end

  def organization_visible_for_account(account, organization_id) do
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
