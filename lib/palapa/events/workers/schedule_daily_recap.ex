defmodule Palapa.Events.Workers.ScheduleDailyRecap do
  use Oban.Worker, queue: :daily_recaps, max_attempts: 5

  alias Palapa.Events
  alias Palapa.Accounts
  alias Palapa.Repo

  @hour_to_send 7

  @impl Oban.Worker
  def perform(_args, _job) do
    Repo.transaction(fn ->
      Accounts.accounts_with_daily_recap_subscription()
      |> Repo.stream(max_rows: 100)
      |> Stream.filter(&hour_to_send?/1)
      |> Stream.each(&enqueue_daily_recap_job/1)
      |> Stream.run()
    end)
  end

  defp hour_to_send?(account) do
    timezone = account.timezone || "UTC"

    Timex.now(timezone)
    |> Map.get(:hour)
    |> Kernel.==(@hour_to_send)
  end

  defp enqueue_daily_recap_job(account) do
    %{"account_id" => account.id}
    |> Events.Workers.DailyRecap.new()
    |> Oban.insert()
  end
end
