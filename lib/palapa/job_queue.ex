defmodule Palapa.JobQueue do
  use EctoJob.JobQueue, table_name: "jobs"

  alias Palapa.Repo
  alias Palapa.Organizations
  alias Palapa.Billing

  def perform(multi, %{"type" => "update_stripe_customer", "customer_id" => customer_id}) do
    customer = Billing.Customers.get_customer(customer_id)

    if !customer do
      # if the customer doesn't exists anymore, we let the job delete itself
      Repo.transaction(multi)
    else
      multi
      |> Ecto.Multi.run(:update_stripe_customer, fn _repo, _changes ->
        Billing.Customers.update_stripe_customer(customer)
      end)
      |> Repo.transaction()
    end
  end

  def perform(multi, %{"type" => "cancel_subscription", "organization_id" => organization_id}) do
    organization = Organizations.get(organization_id)

    if !organization do
      Repo.transaction(multi)
    else
      Billing.Subscriptions.cancel_subscription(organization)
    end
  end
end
