defmodule PalapaWeb.Billing.StripeWebhookController do
  use PalapaWeb, :controller

  alias Palapa.Billing

  plug :verify_stripe_signature

  def verify_stripe_signature(conn, _params) do
    # In order to verify the Stripe signature, the raw request body has been cached by the CacheRawBody plug
    payload = conn.assigns[:raw_body]
    signature = Plug.Conn.get_req_header(conn, "stripe-signature") |> List.first()
    secret = Application.get_env(:stripity_stripe, :webhook_secret)

    if conn.assigns[:ignore_stripe_signature] do
      conn
    else
      case Stripe.Webhook.construct_event(payload, signature, secret) do
        {:ok, %Stripe.Event{} = event} ->
          assign(conn, :event, event)

        {:error, message} ->
          conn
          |> send_resp(:forbidden, message)
          |> halt()
      end
    end
  end

  def create(conn = %{assigns: %{event: %Stripe.Event{type: "invoice.created"} = event}}, _params) do
    stripe_invoice = event.data.object
    customer = Billing.get_customer_by_stripe_id!(stripe_invoice.customer)

    invoice_attrs = %{
      stripe_invoice_id: stripe_invoice.id,
      created_at: DateTime.from_unix!(stripe_invoice.created),
      number: stripe_invoice.number,
      status: stripe_invoice.status,
      total: stripe_invoice.total,
      hosted_invoice_url: stripe_invoice.hosted_invoice_url,
      pdf_url: stripe_invoice.invoice_pdf
    }

    case Billing.create_invoice(customer, invoice_attrs) do
      {:ok, invoice} ->
        send_resp(conn, :ok, "Created invoice #{invoice.id}")

      {:error, _changeset} ->
        send_resp(conn, :bad_request, "Error while creating invoice")
    end
  end

  def create(
        conn = %{assigns: %{event: %Stripe.Event{type: "invoice.payment_succeeded"} = event}},
        _params
      ) do
    stripe_invoice = event.data.object
    invoice = Billing.get_invoice_by_stripe_id!(stripe_invoice.id)

    case Billing.update_invoice(invoice, %{status: stripe_invoice.status}) do
      {:ok, invoice} ->
        send_resp(conn, :ok, "Updated invoice status #{invoice.id} #{invoice.status}")

      {:error, _changeset} ->
        send_resp(conn, :bad_request, "Error while updating invoice status")
    end
  end

  def create(
        conn = %{assigns: %{event: %Stripe.Event{type: "customer.subscription.updated"} = event}},
        _params
      ) do
    stripe_subscription = event.data.object
    subscription = Billing.get_subscription_by_stripe_id!(stripe_subscription.id)

    case Billing.update_subscription(subscription, %{status: stripe_subscription.status}) do
      {:ok, subscription} ->
        send_resp(conn, :ok, "Updated subscription status : #{subscription.status}")

      {:error, _changeset} ->
        send_resp(conn, :bad_request, "Error while updating subscription status")
    end
  end
end
