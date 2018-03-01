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

  def scope_by_ids(query, ids) when is_list(ids) do
    query
    |> where([q], q.id in ^ids)
  end

  def generate_token(length \\ 32) do
    :crypto.strong_rand_bytes(length)
    |> Base.encode64()
    |> binary_part(0, length)
  end
end
