defmodule PalapaWeb.Billing.PaymentController do
  use PalapaWeb, :controller
  alias Palapa.Billing

  plug Bodyguard.Plug.Authorize,
    policy: Palapa.Billing.Policy,
    action: :update_billing,
    user: {PalapaWeb.Current, :current_member},
    fallback: PalapaWeb.FallbackController

  plug(:put_layout, :account)
  plug :put_navigation, "accounts"

  def new(conn, _params) do
    current_subscription = Billing.get_subscription(current_organization(conn))

    case Billing.pay_invoice(current_subscription.stripe_latest_invoice_id) do
      {:ok, _} ->
        redirect(conn, to: Routes.dashboard_url(conn, :index, current_organization(conn)))

      # Display the 3DSecure challenge
      {:error, %Stripe.Error{extra: %{card_code: :invoice_payment_intent_requires_action}}} ->
        payment_intent = Billing.get_payment_intent(current_subscription.stripe_subscription_id)
        render(conn, "new.html", payment_intent: payment_intent)

      {:error, %Stripe.Error{message: message}} ->
        conn
        |> put_flash(
          :error,
          "An unexpected error occured : #{message}. The payment has been cancelled."
        )
        |> redirect(to: Routes.organization_path(conn, :index))
    end
  end
end
