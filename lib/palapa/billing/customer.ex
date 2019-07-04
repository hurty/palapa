defmodule Palapa.Billing.Customer do
  use Palapa.Schema

  alias Palapa.Organizations.Organization
  alias Palapa.Billing.Invoice

  schema "customers" do
    has_one(:organization, Organization)
    has_many(:invoices, Invoice)
    timestamps()

    field(:stripe_customer_id, :string)
    field(:stripe_token_id, :string, virtual: true)

    field(:billing_name, :string)
    field(:billing_email, :string)
    field(:billing_address, :string)
    field(:billing_city, :string)
    field(:billing_postcode, :string)
    field(:billing_state, :string)
    field(:billing_country, :string)
    field(:vat_number, :string)

    field(:card_brand, :string)
    field(:card_last_4, :string)
    field(:card_expiration_month, :integer)
    field(:card_expiration_year, :integer)
  end

  def changeset(customer, attrs) do
    customer
    |> cast(attrs, [:stripe_customer_id])
    |> unique_constraint(:stripe_customer_id)
  end

  def billing_infos_changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :stripe_token_id,
      :billing_name,
      :billing_email,
      :billing_address,
      :billing_postcode,
      :billing_city,
      :billing_state,
      :billing_country,
      :vat_number,
      :card_brand,
      :card_last_4,
      :card_expiration_month,
      :card_expiration_year
    ])
    |> validate_required([
      :stripe_token_id,
      :billing_name,
      :billing_email,
      :card_brand,
      :card_last_4,
      :card_expiration_month,
      :card_expiration_year
    ])
  end

  def edit_billing_infos_changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :billing_name,
      :billing_email,
      :billing_address,
      :billing_postcode,
      :billing_city,
      :billing_state,
      :billing_country,
      :vat_number
    ])
    |> validate_required([
      :billing_name,
      :billing_email
    ])
  end

  def payment_method_changeset(customer, attrs) do
    customer
    |> cast(attrs, [
      :stripe_token_id,
      :card_brand,
      :card_last_4,
      :card_expiration_month,
      :card_expiration_year
    ])
    |> validate_required([
      :stripe_token_id,
      :card_brand,
      :card_last_4,
      :card_expiration_month,
      :card_expiration_year
    ])
  end
end
