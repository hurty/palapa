defmodule Palapa.JobQueue do
  use EctoJob.JobQueue, table_name: "jobs"

  alias Palapa.Repo

  def perform(multi, %{"type" => "update_stripe_customer", "customer_id" => customer_id}) do
    customer = Palapa.Billing.get_customer(customer_id)

    if !customer do
      # if the customer doesn't exists anymore, we let the job delete itself
      Repo.transaction(multi)
    else
      multi
      |> Ecto.Multi.run(:update_stripe_customer, fn _repo, _changes ->
        Palapa.Billing.update_stripe_customer(customer)
      end)
      |> Repo.transaction()
    end
  end
end
