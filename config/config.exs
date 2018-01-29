# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :palapa, ecto_repos: [Palapa.Repo]

# Configures the endpoint
config :palapa, PalapaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tQLdy7coYkn7is0vc8/NkVWR8dx8F40oC7QWhY2k74ZjKJ22i7nTsOnqp4NUUeDN",
  render_errors: [view: PalapaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Palapa.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
