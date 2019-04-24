defmodule Palapa.Billing.Customer do
  use Palapa.Schema
  alias Palapa.Organizations.Organization

  schema "customers" do
    has_many(:organization, Organization)

    field(:email, :string)
    field(:last_payment_at, :utc_datetime)
    field(:stripe_customer_id, :string)
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:last_payment_at, :stripe_customer_id])
  end

  def billing_infos_changeset(customer, attrs) do
    customer
    |> cast(attrs, [:email])
  end
end
