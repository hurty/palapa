defmodule Palapa.Billing.Subscription do
  use Palapa.Schema

  alias Palapa.Billing.{Customer, SubscriptionStatusEnum}
  alias Palapa.Organizations.Organization

  schema("subscriptions") do
    belongs_to(:organization, Organization)
    belongs_to(:customer, Customer)

    field(:status, SubscriptionStatusEnum)
    field(:stripe_subscription_id, :string)
    field(:stripe_latest_invoice_id, :string)
  end

  def changeset(subscription \\ %__MODULE__{}, attrs) do
    subscription
    |> cast(attrs, [:status, :stripe_subscription_id, :stripe_latest_invoice_id])
    |> unique_constraint(:stripe_subscription_id)
  end
end
