defmodule PalapaWeb.StripeWebhookController do
  use PalapaWeb, :controller

  def create(conn, _params) do
    # In order to verify the Stripe signature, the raw request body has been cached by the CacheRawBody plug
    payload = conn.assigns[:raw_body]
    signature = Plug.Conn.get_req_header(conn, "stripe-signature") |> List.first()
    secret = Application.get_env(:stripity_stripe, :webhook_secret)

    case Stripe.Webhook.construct_event(payload, signature, secret) do
      {:ok, %Stripe.Event{} = event} ->
        case Palapa.Billing.Events.handle_event(event) do
          {:ok, event} ->
            send_resp(conn, :ok, "Stripe event handled #{event.type} #{event.id}")

          {:error, event, reason} ->
            send_resp(
              conn,
              :bad_request,
              "Error while handling Stripe event #{event.type} #{event.id} (#{reason})"
            )
        end

      {:error, reason} ->
        send_resp(conn, :bad_request, reason)
    end
  end
end
