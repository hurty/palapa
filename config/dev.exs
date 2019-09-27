use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application.
config :palapa, PalapaWeb.Endpoint,
  http: [port: 4000],
  # https: [
  #   port: 4001,
  #   cipher_suite: :strong,
  #   certfile: "priv/cert/selfsigned.pem",
  #   keyfile: "priv/cert/selfsigned_key.pem"
  # ],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# command from your terminal:
#
#     openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" -keyout priv/server.key -out priv/server.pem
#
# The `http:` config above can be replaced with:
#
#     https: [port: 4000, keyfile: "priv/server.key", certfile: "priv/server.pem"],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :palapa, PalapaWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/palapa_web/views/.*(ex)$},
      ~r{lib/palapa_web/templates/.*(eex)$},
      ~r{lib/my_app_web/live/.*(ex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Configure your database
config :palapa, Palapa.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "palapa_dev",
  hostname: "localhost",
  pool_size: 10

config :stripity_stripe, api_key: "sk_test_oU4pHn8mHni24tRxngf5eRHy00Yg3UvggS"
config :stripity_stripe, webhook_secret: "whsec_LRI0vYyl1V9s0UcaCvJ6NbKQCjjpljhS"
config :stripity_stripe, json_library: Jason

config :appsignal, :config, active: false
