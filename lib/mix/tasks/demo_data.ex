defmodule Mix.Tasks.Demo do
  use Mix.Task

  @shortdoc "Insert a demo workspace"
  def run(_) do
    Mix.Task.run("ecto.drop")
    Mix.Task.run("ecto.create")
    Mix.Task.run("ecto.migrate")
    Mix.Task.run("app.start")
    Palapa.Factory.insert_pied_piper!(:full)
  end
end
