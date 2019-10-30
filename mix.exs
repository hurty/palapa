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
        :bamboo_mailjet,
        :arc_ecto,
        :scrivener_ecto,
        :scrivener_html
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "test/support"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.0", override: true},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:ecto, "~> 3.0", override: true},
      {:ecto_sql, "~> 3.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_view, github: "phoenixframework/phoenix_live_view"},
      {:phoenix_live_reload, "~> 1.2.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:html_sanitize_ex,
       git: "https://github.com/rrrene/html_sanitize_ex.git",
       ref: "c9b05d982e988a554b56b1f9ab40df89ae14a9cf"},
      {:comeonin, "~> 4.0"},
      {:bcrypt_elixir, "~> 1.0"},
      {:bodyguard, "~> 2.2"},
      {:ecto_enum, "~> 1.0"},
      {:bamboo, "~> 1.3.0"},
      {:bamboo_mailjet, "~> 0.1.0"},
      {:timex, "~> 3.4"},
      {:arc, "~> 0.11.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:sweet_xml, "~> 0.6"},
      {:arc_ecto, "~> 0.11.0"},
      {:scrivener_ecto, "~> 2.1.1"},
      {:scrivener_html, "~> 1.8"},
      {:appsignal, "~> 1.0"},
      {:floki, "~> 0.20.0"},
      {:stripity_stripe, "~> 2.7.0"},
      {:mox, "~> 0.5", only: :test},
      {:ecto_job, "~> 3.0"},
      {:money, "~> 1.4"},
      {:countries, "~> 1.5"}
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
