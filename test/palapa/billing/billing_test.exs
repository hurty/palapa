defmodule Palapa.BillingTest do
  use Palapa.DataCase

  import Palapa.Factory
  alias Palapa.Billing

  @invoice_attrs %{
    stripe_invoice_id: "in_000",
    created_at: DateTime.utc_now(),
    number: "813B9B8B-0001",
    hosted_invoice_url: "https://pay.stripe.com/invoice/invst_sOOfO7gC1QJnlAanPH6P1g4deC",
    pdf_url: "https://pay.stripe.com/invoice/invst_sOOfO7gC1QJnlAanPH6P1g4deC/pdf",
    status: "open",
    total: 29
  }

  setup do
    {:ok, workspace: insert_pied_piper!()}
  end

  test "creates an invoice", %{workspace: workspace} do
    assert {:ok, _invoice} = Billing.create_invoice(workspace.customer, @invoice_attrs)
  end

  test "updates an invoice", %{workspace: workspace} do
    {:ok, invoice} = Billing.create_invoice(workspace.customer, @invoice_attrs)
    assert {:ok, invoice} = Billing.update_invoice(invoice, %{status: "paid"})
    assert invoice.status == "paid"
  end
end
