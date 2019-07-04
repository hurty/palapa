defmodule Palapa.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def up do
    create(table(:customers)) do
      timestamps()
      add(:stripe_customer_id, :string)
      add(:billing_name, :string)
      add(:billing_email, :string)
      add(:billing_address, :string)
      add(:billing_city, :string)
      add(:billing_postcode, :string)
      add(:billing_state, :string)
      add(:billing_country, :string)
      add(:vat_number, :string)
      add(:card_brand, :string)
      add(:card_last_4, :string)
      add(:card_expiration_month, :integer)
      add(:card_expiration_year, :integer)
    end

    create(unique_index(:customers, :stripe_customer_id))

    Palapa.Billing.SubscriptionStatusEnum.create_type()

    create(table(:subscriptions)) do
      add(:customer_id, references(:customers, on_delete: :delete_all))
      add(:organization_id, references(:organizations, on_delete: :delete_all))
      add(:status, :subscription_status, default: "trialing")
      add(:stripe_subscription_id, :string)
    end

    create(index(:subscriptions, :customer_id))
    create(index(:subscriptions, :organization_id))
    create(unique_index(:subscriptions, :stripe_subscription_id))

    alter(table(:organizations)) do
      add(:customer_id, references(:customers, on_delete: :nilify_all))
    end
  end

  def down do
    alter(table(:organizations)) do
      remove(:customer_id)
    end

    drop(table(:subscriptions))
    drop(table(:customers))

    Palapa.Billing.SubscriptionStatusEnum.drop_type()
  end
end
