defmodule Palapa.Users.Policy do
  use Palapa.Policy

  def authorize(:switch_organization, %Accounts.Account{} = account, organization) do
    account = account |> Repo.preload(:organizations, force: true)
    organization in account.organizations
  end

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
