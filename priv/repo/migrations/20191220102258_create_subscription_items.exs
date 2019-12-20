defmodule Palapa.Repo.Migrations.CreateSubscriptionItems do
  use Ecto.Migration

  def change do
    alter(table(:organizations)) do
      remove(:customer_id)
      add(:subscription_id, references(:subscriptions, on_delete: :delete_all))
      add(:stripe_subscription_item_id, :string)
    end

    create(index(:organizations, :subscription_id))

    alter(table(:subscriptions)) do
      remove(:organization_id)
    end
  end
end
