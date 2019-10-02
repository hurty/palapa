defmodule PalapaWeb.Settings.Billing.BillingErrorController do
  use PalapaWeb, :controller
  alias Palapa.Billing

  plug(:put_layout, "minimal.html")

  def show(conn, _params) do
    case Billing.get_billing_status(current_organization(conn)) do
      :trial_has_ended ->
        render(conn, "trial_has_ended.html")

      :incomplete_expired ->
        render(conn, "waiting_for_payment.html")

      _ ->
        redirect(conn, to: Routes.dashboard_path(conn, :index, current_organization(conn)))
    end
  end
end
