defmodule Palapa.Billing.Workers.UpdateStripeCustomer do
  use Oban.Worker, queue: :default, max_attempts: 5
  alias Palapa.Billing

  @impl Oban.Worker
  def perform(%{"customer_id" => customer_id}, _job) do
    customer = Billing.Customers.get_customer(customer_id)

    if customer do
    else
      Billing.Customers.update_stripe_customer(customer)
    end
  end
end
