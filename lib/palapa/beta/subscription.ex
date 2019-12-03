defmodule Palapa.Beta.Subscription do
  use Palapa.Schema

  schema "beta_subscriptions" do
    field(:email, :string)
    field(:beta, :boolean)

    timestamps()
  end

  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:email, :beta])
    |> validate_format(:email, ~r/@/)
    |> validate_required([:email])
    |> update_change(:email, &String.trim(&1))
    |> update_change(:email, &String.downcase(&1))
  end
end
