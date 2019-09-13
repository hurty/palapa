defmodule Palapa.Events.Recap do
  alias Palapa.Events
  alias Palapa.Repo

  import Ecto.Query

  # Collect all the events of the past day for a specific member
  def build_recap(member, until \\ Timex.now()) do
    from = Timex.shift(until, day: -1)

    Events.all_events_query(member)
    |> where([e], e.inserted_at >= ^from and e.inserted_at <= ^until)
    |> Repo.all()
  end

  # Build email template and send to user email address
  def send_recap(recap, user) do
  end
end
