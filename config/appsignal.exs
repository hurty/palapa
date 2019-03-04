use Mix.Config

config :appsignal, :config,
  name: "palapa",
  push_api_key: System.get_env("APPSIGNAL_API_KEY"),
  env: Mix.env()
