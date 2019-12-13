defmodule Palapa.Organizations.Workers.DeleteOrganization do
  use Oban.Worker, queue: :daily_recaps, max_attempts: 5

  @impl Oban.Worker
  def perform(%{"organization_id" => organization_id}, _job) do
    organization = Palapa.Organizations.get(organization_id)

    if organization do
      Palapa.Organizations.delete(organization)
    end
  end
end
