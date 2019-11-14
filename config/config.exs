# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :palapa, env: Mix.env()

# General application configuration
config :palapa, ecto_repos: [Palapa.Repo]

# Configures the endpoint
config :palapa, PalapaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tQLdy7coYkn7is0vc8/NkVWR8dx8F40oC7QWhY2k74ZjKJ22i7nTsOnqp4NUUeDN",
  render_errors: [view: PalapaWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Palapa.PubSub, adapter: Phoenix.PubSub.PG2],
  instrumenters: [Appsignal.Phoenix.Instrumenter],
  live_view: [
    signing_salt: "nuvKwHRzugfh2M0cv2XIaZpuzoNhkZ2q"
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :palapa,
  email_support: "support@palapa.io",
  email_transactionnal: {"Palapa", "do-not-reply@palapa.io"}

config :palapa, PalapaWeb.Gettext, locales: ["en", "fr"], default_locale: "en"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :palapa, Palapa.Mailer,
  adapter: Bamboo.LocalAdapter,
  deliver_later_strategy: Bamboo.TaskSupervisorStrategy

config :waffle, storage: Waffle.Storage.Local
config :scrivener_html, routes_helper: PalapaWeb.Router.Helpers

# config :verk,
#   queues: [default: 25, priority: 10],
#   max_retry_count: 10,
#   poll_interval: 5000,
#   start_job_log_level: :info,
#   done_job_log_level: :info,
#   fail_job_log_level: :info,
#   node_id: "1",
#   redis_url: {:system, "REDIS_URL", "redis://127.0.0.1:6379"}

config :phoenix, :template_engines,
  eex: Appsignal.Phoenix.Template.EExEngine,
  exs: Appsignal.Phoenix.Template.ExsEngine

config :palapa, Palapa.Repo,
  log: :debug,
  migration_primary_key: [name: :id, type: :binary_id]

config :stripity_stripe, json_library: Jason
config :waffle, version_timeout: 30_000

config :arc_gcs,
  hackney_opts: [
    timeout: 30_000,
    recv_timeout: 30_000
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
