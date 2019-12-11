defmodule Palapa.Events.Workers.ScheduleDailyRecap do
  use Oban.Worker, queue: :daily_recaps, max_attempts: 5

  alias Palapa.Events
  alias Palapa.Accounts
  alias Palapa.Repo

  @hour_to_send 16

  @impl Oban.Worker
  def perform(_args, _job) do
    Repo.transaction(fn ->
      Accounts.active(Accounts.Account)
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
    IO.inspect(account)

    %{"account_id" => account.id}
    |> Events.Workers.DailyRecap.new()
    |> Oban.insert()
  end
end
