defmodule Palapa.Policy do
  defmacro __using__(_) do
    quote do
      @behaviour Bodyguard.Policy

      alias Palapa.Organizations.Member, warn: false
      alias Palapa.Accounts, warn: false
      alias Palapa.Repo, warn: false
    end
  end
end
