defmodule Palapa.Billing.Workers.CancelSubscription do
  use Oban.Worker, queue: :default, max_attempts: 5

  @impl Oban.Worker
  def perform(%{"organization_id" => organization_id}, _job) do
    organization = Palapa.Organizations.get(organization_id)

    if organization do
      Palapa.Billing.Subscriptions.cancel_subscription(organization)
    end
  end
end
