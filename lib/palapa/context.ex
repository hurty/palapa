defmodule Palapa.Context do
  defmacro __using__(_) do
    quote do
      import Ecto.Query
      import Ecto.Changeset
      alias Palapa.Repo
      alias Palapa.Access
    end
  end
end
