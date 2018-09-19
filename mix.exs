defmodule Palapa.Mixfile do
  use Mix.Project

  def project do
    [
      app: :palapa,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Palapa.Application, []},
      extra_applications: [
        :appsignal,
        :logger,
        :runtime_tools,
        :timex,
        :bamboo,
        :arc_ecto,
        :scrivener_ecto,
        :scrivener_html
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:prod), do: ["lib", "test/support"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:jason, "~> 1.0"},
      {:html_sanitize_ex,
       git: "https://github.com/rrrene/html_sanitize_ex.git",
       ref: "c9b05d982e988a554b56b1f9ab40df89ae14a9cf"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:bodyguard, "~> 2.2"},
      {:ecto_enum, "~> 1.0"},
      {:bamboo, "~> 1.0.0"},
      {:timex, "~> 3.2"},
      {:arc, "~> 0.10.0"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:httpoison, "~> 0.13"},
      {:poison, "~> 3.1"},
      {:sweet_xml, "~> 0.6"},
      {:arc_ecto, "~> 0.10.0"},
      {:scrivener_ecto, "~> 1.0"},
      {:scrivener_html, "~> 1.7"},
      {:verk, "~> 1.4.0"},
      {:hackney, "~> 1.13.0", override: true},
      {:appsignal, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      # "assets.compile": &compile_assets/1,
      test: [
        "ecto.create --quiet",
        "ecto.migrate",
        "test"
      ]
    ]
  end

  # defp compile_assets(_) do
  #   Mix.shell().cmd("assets/node_modules/brunch/bin/brunch build assets/")
  # end
end
