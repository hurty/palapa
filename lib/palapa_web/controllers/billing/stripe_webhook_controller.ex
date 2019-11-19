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

  def create(conn = %{assigns: %{event: event}}, params) do
    handle_event(conn, event, params)
  end

  defp handle_event(conn, %{type: "invoice.created"} = event, _params) do
    stripe_invoice = event.data.object
    customer = Billing.Customers.get_customer_by_stripe_id!(stripe_invoice.customer)

    invoice_attrs = %{
      stripe_invoice_id: stripe_invoice.id,
      created_at: DateTime.from_unix!(stripe_invoice.created),
      number: stripe_invoice.number,
      status: stripe_invoice.status,
      total: stripe_invoice.total,
      hosted_invoice_url: stripe_invoice.hosted_invoice_url,
      pdf_url: stripe_invoice.invoice_pdf
    }

    case Billing.Invoices.create_invoice(customer, invoice_attrs) do
      {:ok, invoice} ->
        send_resp(conn, :ok, gettext("Created invoice %{invoice_id}", %{invoice_id: invoice.id}))

      {:error, _changeset} ->
        send_resp(conn, :bad_request, gettext("Error while creating invoice"))
    end
  end

  defp handle_event(conn, %{type: "invoice.updated"} = event, _params) do
    stripe_invoice = event.data.object
    invoice = Billing.Invoices.get_invoice_by_stripe_id!(stripe_invoice.id)

    case Billing.Invoices.update_invoice(invoice, %{status: stripe_invoice.status}) do
      {:ok, invoice} ->
        send_resp(
          conn,
          :ok,
          gettext("Updated invoice status %{invoice_id} %{invoice_status}", %{
            invoice_id: invoice.id,
            invoice_status: invoice.status
          })
        )

      {:error, _changeset} ->
        send_resp(conn, :bad_request, gettext("Error while updating invoice status"))
    end
  end

  defp handle_event(conn, %{type: "customer.subscription.updated"} = event, _params) do
    stripe_subscription = event.data.object
    subscription = Billing.Subscriptions.get_subscription_by_stripe_id!(stripe_subscription.id)

    case Billing.Subscriptions.update_subscription(subscription, %{
           status: stripe_subscription.status,
           stripe_latest_invoice_id: stripe_subscription.latest_invoice
         }) do
      {:ok, subscription} ->
        send_resp(
          conn,
          :ok,
          gettext("Updated subscription status : %{subscription_status}", %{
            subscription_status: subscription.status
          })
        )

      {:error, _changeset} ->
        send_resp(conn, :bad_request, gettext("Error while updating subscription status"))
    end
  end
end
