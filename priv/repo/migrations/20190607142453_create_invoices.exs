defmodule Palapa.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create(table(:invoices)) do
      add(:customer_id, references(:customers, on_delete: :delete_all))
      add(:stripe_invoice_id, :string)
      add(:number, :string)
      add(:hosted_invoice_url, :string)
      add(:pdf_url, :string)
      add(:period_start, :utc_datetime)
      add(:status, :string)
      add(:total, :integer)
      timestamps()
    end

    create(index(:invoices, :customer_id))
    create(unique_index(:invoices, :stripe_invoice_id))
  end
end
