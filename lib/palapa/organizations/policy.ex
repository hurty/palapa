defmodule Palapa.Organizations.Policy do
  @behaviour Bodyguard.Policy
  alias Palapa.Repo, warn: false
  import Ecto.Query, warn: false

  # Catch-all: deny everything else
  def authorize(_, _, _), do: false
end
