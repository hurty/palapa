use Mix.Config

# For production, we often load configuration from external
# sources, such as your system environment. For this reason,
# you won't find the :http configuration below, but set inside
# PalapaWeb.Endpoint.init/2 when load_from_system_env is
# true. Any dynamic configuration should be done there.
#
# Don't forget to configure the url host to something meaningful,
# Phoenix uses this information when generating URLs.
#
# Finally, we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the mix phx.digest task
# which you typically run after static files are built.
config :palapa, PalapaWeb.Endpoint,
  load_from_system_env: true,
  url: [host: "palapa.cleverapps.io", port: System.get_env("PORT")],
  cache_static_manifest: "priv/static/cache_manifest.json",
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info

config :palapa, Palapa.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: System.get_env("POSTGRESQL_ADDON_HOST"),
  username: System.get_env("POSTGRESQL_ADDON_USER"),
  database: System.get_env("POSTGRESQL_ADDON_DB"),
  password: System.get_env("POSTGRESQL_ADDON_PASSWORD"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "1")

config :palapa, Palapa.Mailer,
  adapter: Bamboo.MailgunAdapter,
  deliver_later_strategy: Palapa.Mailer.DeliverLaterStrategy
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN"),

config :arc,
  storage: Arc.Storage.S3,
  bucket: "palapa"

config :ex_aws,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_KEY"),
  region: "eu-west-3"

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :palapa, PalapaWeb.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [:inet6,
#               port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :palapa, PalapaWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :palapa, PalapaWeb.Endpoint, server: true
#

# Finally import the config/prod.secret.exs
# which should be versioned separately.
# import_config "prod.secret.exs"
