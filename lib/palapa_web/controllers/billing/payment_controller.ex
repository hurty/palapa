defmodule PalapaWeb.Billing.PaymentController do
  use PalapaWeb, :controller
  alias Palapa.Billing

  plug(:put_layout, :account)
  plug :put_navigation, "accounts"

  def new(conn, _params) do
    current_subscription = Billing.get_subscription(current_organization(conn))
    success_redirect_url = Routes.dashboard_url(conn, :index, current_organization(conn))
    error_redirect_url = Routes.payment_method_url(conn, :edit, current_organization(conn))

    case Billing.pay_invoice(current_subscription.stripe_latest_invoice_id) do
      {:ok, _} ->
        redirect(conn, to: success_redirect_url)

      # Display the 3DSecure challenge
      {:error, %Stripe.Error{extra: %{card_code: :invoice_payment_intent_requires_action}}} ->
        payment_intent = Billing.get_payment_intent(current_subscription.stripe_subscription_id)

        render(conn, "new.html",
          payment_intent: payment_intent,
          success_redirect_url: success_redirect_url,
          error_redirect_url: error_redirect_url
        )

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
