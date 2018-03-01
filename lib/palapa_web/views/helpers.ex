defmodule PalapaWeb.Helpers do
  def format_datetime(datetime) when is_nil(datetime), do: nil

  def format_datetime(datetime) do
    {:ok, formatted} = Timex.format(datetime, "{ISO:Extended}")
    formatted
  end

  def time_from_now(datetime) when is_nil(datetime), do: nil

  def time_from_now(datetime) do
    Timex.from_now(datetime)
  end
end
