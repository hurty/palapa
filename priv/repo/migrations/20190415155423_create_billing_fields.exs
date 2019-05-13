defmodule Palapa.Repo.Migrations.CreateBillingFields do
  use Ecto.Migration

  def change do
    create(table(:customers)) do
      add(:stripe_customer_id, :string)
      add(:stripe_subscription_id, :string)
      add(:billing_name, :string)
      add(:billing_email, :string)
      add(:billing_address, :string)
      add(:billing_city, :string)
      add(:billing_postcode, :string)
      add(:billing_state, :string)
      add(:billing_country, :string)
      add(:vat_number, :string)
      add(:last_payment_at, :utc_datetime)
      add(:card_brand, :string)
      add(:card_last_4, :string)
      add(:card_expiration_month, :integer)
      add(:card_expiration_year, :integer)
    end

    alter(table(:organizations)) do
      add(:valid_until, :utc_datetime)
      add(:customer_id, references(:customers, on_delete: :nilify_all))
    end
  end
end
