defmodule Palapa.Billing.Customer do
  use Palapa.Schema
  alias Palapa.Organizations.Organization

  schema "customers" do
    has_many(:organizations, Organization)

    field(:billing_name, :string)
    field(:billing_email, :string)
    field(:billing_address, :string)
    field(:billing_city, :string)
    field(:billing_postcode, :string)
    field(:billing_country, :string)
    field(:vat_number, :string)
    field(:card_brand, :string)
    field(:card_last_4, :string)
    field(:cardholder_name, :string)
    field(:last_payment_at, :utc_datetime)
    field(:stripe_customer_id, :string)
    field(:stripe_token_id, :string)
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:last_payment_at, :stripe_customer_id])
  end

  def billing_infos_changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :billing_name,
      :billing_email,
      :billing_address,
      :billing_postcode,
      :billing_city,
      :billing_country,
      :vat_number,
      :cardholder_name,
      :card_brand,
      :card_last_4,
      :stripe_token_id
    ])
    |> validate_required([
      :billing_name,
      :billing_email,
      :card_brand,
      :card_last_4,
      :cardholder_name,
      :stripe_token_id
    ])
  end
end
