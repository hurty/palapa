defmodule Palapa.Beta.Subscription do
  use Palapa.Schema

  schema "beta_subscriptions" do
    field(:email, :string)
    field(:beta, :boolean)
    field(:invitation, :string)
    field(:used, :boolean)
    timestamps()
  end

  def changeset(subscription, attrs) do
    subscription
    |> cast(attrs, [:email, :beta, :used])
    |> validate_format(:email, ~r/@/)
    |> validate_required([:email])
    |> update_change(:email, &String.trim(&1))
    |> update_change(:email, &String.downcase(&1))
  end
end
