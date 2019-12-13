defmodule Palapa.Accounts.Timezones do
  def timezones_list do
    Tzdata.zone_list()
  end
end
