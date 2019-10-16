defmodule Palapa.Billing.Invoices do
  use Palapa.Context

  alias Palapa.Billing
  alias Palapa.Billing.{Invoice}

  def get_invoice_by_stripe_id!(stripe_invoice_id) do
    Repo.get_by!(Invoice, stripe_invoice_id: stripe_invoice_id)
  end

  def list_invoices(organization) do
    organization
    |> Ecto.assoc(:invoices)
    |> order_by([i], desc: i.inserted_at)
    |> Repo.all()
  end

  def create_invoice(customer, attrs) do
    %Invoice{}
    |> Invoice.changeset(attrs)
    |> put_assoc(:customer, customer)
    |> Repo.insert(on_conflict: :nothing)
  end

  def update_invoice(invoice, attrs) do
    invoice
    |> Invoice.changeset(attrs)
    |> Repo.update()
  end

  def pay_invoice(stripe_invoice_id) when is_binary(stripe_invoice_id) do
    Billing.stripe_adapter().pay_invoice(stripe_invoice_id)
  end
end
