defmodule PalapaWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.DSL

      alias Palapa.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import PalapaWeb.Router.Helpers
      import Wallaby.Query
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Palapa.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Palapa.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(Palapa.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
