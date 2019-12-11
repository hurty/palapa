defmodule Palapa.Events.Workers.DailyRecap do
  use Oban.Worker, queue: :daily_recaps, max_attempts: 5, unique: [period: 60 * 60 * 24]

  @impl Oban.Worker
  def perform(%{"account_id" => account_id}, _job) do
    account = Palapa.Accounts.get(account_id)

    if account do
      Palapa.Events.send_daily_recaps(account)
    end
  end
end
