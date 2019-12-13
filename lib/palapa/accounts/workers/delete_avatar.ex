defmodule Palapa.Accounts.Workers.DeleteAvatar do
  use Oban.Worker, queue: :default, max_attempts: 5

  @impl Oban.Worker
  def perform(%{"account_id" => account_id}, _job) do
    account = Palapa.Accounts.get(account_id)

    if account && account.avatar do
      Palapa.Avatar.delete({account.avatar, account})
    end
  end
end
