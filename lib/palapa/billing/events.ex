defmodule Palapa.Billing.Events do
  use Palapa.Context

  def handle_event(%Stripe.Event{type: "invoice.created"} = _event) do
    IO.puts("NEW INVOICE !")
  end

  def handle_event(%Stripe.Event{type: "invoice.payment_succeeded"} = _event) do
    IO.puts("PAYMENT SUCCEEDED !")
  end

  def handle_event(%Stripe.Event{type: "invoice.payment_failed"} = _event) do
    IO.puts("PAYMENT FAILED !")
  end
end
