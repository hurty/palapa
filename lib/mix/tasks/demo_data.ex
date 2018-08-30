defmodule Mix.Tasks.Demo do
  use Mix.Task

  @shortdoc "Insert a demo workspace"
  def run(args) do
    parsed = OptionParser.parse(args, switches: [drop: :boolean])
    IO.inspect(parsed)

    case parsed do
      {[drop: true], _, _} ->
        Mix.Task.run("ecto.drop")
        Mix.Task.run("ecto.create")
        Mix.Task.run("ecto.migrate")
    end

    Mix.Task.run("app.start")
    Palapa.Factory.insert_pied_piper!(:full)
  end
end
