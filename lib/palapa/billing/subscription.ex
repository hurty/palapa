defmodule Palapa.Billing.Subscription do
  use Palapa.Schema

  alias Palapa.Billing.{Customer, SubscriptionStatusEnum}
  alias Palapa.Organizations.Organization

  schema("subscriptions") do
    belongs_to(:organization, Organization)
    belongs_to(:customer, Customer)

    field(:stripe_subscription_id, :string)
    field(:status, SubscriptionStatusEnum)
  end

  def changeset(subscription \\ %__MODULE__{}, attrs) do
    subscription
    |> cast(attrs, [:stripe_subscription_id, :status])
    |> unique_constraint(:stripe_subscription_id)
  end
end
