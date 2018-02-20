defmodule Palapa.Dashboard.Policy do
  @behaviour Bodyguard.Policy
  alias Palapa.Organizations.Member
  alias Palapa.Repo, warn: false
  import Ecto.Query, warn: false

  # Owner can do anything
  def authorize(_, %Member{role: :owner}, _), do: true

  # Anybody can see the dashboard
  def authorize(:index_dashboard, _, _), do: true

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
