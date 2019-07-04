defmodule PalapaWeb.Settings.Billing.CustomerView do
  use PalapaWeb, :view

  def countries_list() do
    countries =
      Countries.all()
      |> Enum.map(fn country -> country.name end)
      |> Enum.sort()

    [[key: "", value: ""] | countries]
  end

  def format_money(amount) do
    Money.new(amount, :EUR)
    |> Money.to_string()
  end
end
