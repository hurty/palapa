ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Palapa.Repo, :manual)
Application.put_env(:wallaby, :base_url, PalapaWeb.Endpoint.url())
Application.put_env(:wallaby, :js_errors, true)
{:ok, _} = Application.ensure_all_started(:wallaby)
