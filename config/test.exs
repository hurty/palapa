use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :palapa, PalapaWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :palapa, Palapa.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "palapa_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# Reduce the complexity of the password hashing calculation for much faster tests
config :bcrypt_elixir, :log_rounds, 4