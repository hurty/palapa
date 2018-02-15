defmodule Palapa.Access do
  import Ecto.Query
  alias Palapa.Organizations.Organization

  # Handy authorization functions
  defdelegate(permit(policy, action, user, params \\ []), to: Bodyguard)
  defdelegate(permit!(policy, action, user, params \\ []), to: Bodyguard)
  defdelegate(permit?(policy, action, user, params \\ []), to: Bodyguard)
  # defdelegate(scope(query, user, params \\ [], opts \\ []), to: Bodyguard)

  def scope(query, %Organization{} = organization) do
    query
    |> where(organization_id: ^organization.id)
  end
end
