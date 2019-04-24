defmodule Palapa.Repo.Migrations.CreateBillingFields do
  use Ecto.Migration

  def change do
    create(table(:customers)) do
      add(:stripe_customer_id, :string)
      add(:last_payment_at, :utc_datetime)
    end

    alter(table(:organizations)) do
      add(:valid_until, :utc_datetime)
      add(:customer_id, references(:customers))
    end
  end
end
