defmodule PalapaWeb.Settings.Billing.BillingErrorController do
  use PalapaWeb, :controller
  alias Palapa.Billing

  plug(:put_layout, "minimal.html")

  def show(conn, %{"organization_id" => organization_id}) do
    organization = Palapa.Organizations.get!(organization_id)
    # Check visibility

    IO.inspect(Billing.organization_state(organization), label: "ORG STATE")

    case Billing.organization_state(organization) do
      :trial_has_ended ->
        render(conn, "trial_has_ended.html", organization: organization)

      :waiting_for_payment ->
        render(conn, "waiting_for_payment.html", organization: organization)

      _ ->
        redirect(conn, to: dashboard_path(conn, :index, organization))
    end
  end
end
