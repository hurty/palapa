defmodule PalapaWeb.SubscriptionController do
  use PalapaWeb, :controller

  alias Palapa.Billing
  alias Palapa.Billing.Customer

  plug(:put_layout, :account)
  plug(:put_navigation, "workspaces")

  def new(conn, _params) do
    with :ok <- permit(Billing.Policy, :update_billing, current_member(conn)) do
      customer_changeset = Billing.change_customer_infos(%Customer{})

      render(conn, "new.html", customer_changeset: customer_changeset)
    end
  end
end
