defmodule Palapa.Context do
  defmacro __using__(_) do
    quote do
      alias Palapa.Accounts
      alias Palapa.Organizations
      alias Palapa.Teams

      alias Palapa.Repo
      alias Palapa.Access

      import Ecto.Query
      import Ecto.Changeset
    end
  end
end
