defmodule PalapaWeb.Settings.Billing.CustomerView do
  use PalapaWeb, :view

  def format_money(amount) do
    Money.new(amount, :EUR)
    |> Money.to_string()
  end
end
