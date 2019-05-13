defmodule Palapa.JobQueue do
  use EctoJob.JobQueue, table_name: "jobs"

  alias Palapa.Repo
  alias Palapa.Billing

  def perform(multi, %{
        "type" => "billing_create_stripe_subscription",
        "customer_id" => customer_id,
        "stripe_token_id" => stripe_token_id
      }) do
    customer = Billing.get_customer(customer_id)

    if !customer do
      # if the customer doesn't exists anymore, there is nothing to do and we let the job delete itself.
      Repo.transaction(multi)
    else
      Billing.create_stripe_customer_and_subscription(multi, customer, stripe_token_id)
    end
  end
end
