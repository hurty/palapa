defmodule Palapa.Dashboard do
  import Ecto.Query, warn: false
  import Ecto.Changeset, warn: false
  alias Palapa.Repo, warn: false

  defdelegate(authorize(action, user, params), to: Palapa.Dashboard.Policy)
end
