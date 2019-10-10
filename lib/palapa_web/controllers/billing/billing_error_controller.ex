defmodule PalapaWeb.Billing.BillingErrorController do
  use PalapaWeb, :controller
  alias Palapa.Billing

  plug(:put_layout, "account.html")
  plug(:put_navigation, "workspaces")

  def show(conn, _params) do
    case Billing.get_billing_status(current_organization(conn)) do
      status when status in [:none, :incomplete_expired] ->
        conn
        |> redirect(to: Routes.subscription_path(conn, :new, current_organization(conn)))

      :incomplete ->
        conn
        |> put_flash(:error, "You need to update your payment details to continue")
        |> redirect(to: Routes.payment_method_path(conn, :edit, current_organization(conn)))

      status when status in [:active, :trialing] ->
        redirect(conn, to: Routes.dashboard_path(conn, :index, current_organization(conn)))

      :trial_has_ended ->
        render(conn, "trial_has_ended.html")

      status when status in [:past_due, :canceled] ->
        render(conn, "waiting_for_payment.html")
    end
  end
end
