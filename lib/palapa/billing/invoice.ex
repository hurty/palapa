defmodule Palapa.Billing.Invoice do
  use Palapa.Schema

  schema("invoices") do
    field(:stripe_invoice_id, :string)
    field(:number, :string)
    field(:hosted_invoice_url, :string)
    field(:pdf_url, :string)
    field(:period_start, :utc_datetime)
    field(:status, :string)
    field(:total, :integer)
    timestamps()

    belongs_to(:customer, Palapa.Billing.Customer)
  end

  def changeset(%__MODULE__{} = invoice, attrs) do
    invoice
    |> cast(attrs, [
      :stripe_invoice_id,
      :number,
      :hosted_invoice_url,
      :pdf_url,
      :period_start,
      :status,
      :total
    ])
    |> validate()
  end

  def validate(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_required([:stripe_invoice_id, :number, :pdf_url, :period_start, :status, :total])
    |> unique_constraint(:stripe_invoice_id, name: "invoices_stripe_invoice_id_index")
  end
end
