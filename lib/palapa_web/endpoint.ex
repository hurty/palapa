defmodule PalapaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :palapa
  use Appsignal.Phoenix

  if Application.get_env(:palapa, :sql_sandbox) do
    plug(Phoenix.Ecto.SQL.Sandbox)
  end

  socket "/socket", PalapaWeb.UserSocket, websocket: true
  socket "/live", Phoenix.LiveView.Socket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug(
    Plug.Static,
    at: "/",
    from: :palapa,
    gzip: true,
    only:
      ~w(css fonts images js favicon.ico android-chrome-512x512.png favicon-16x16.png favicon-32x32.png apple-touch-icon.png android-chrome-192x192.png robots.txt)
  )

  plug(
    Plug.Static,
    at: "/uploads",
    from: Path.expand("./uploads"),
    gzip: true
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    length: 200_000_000

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["text/*"],
    body_reader: {PalapaWeb.CacheRawBody, :read_body, []},
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug(
    Plug.Session,
    store: :cookie,
    key: "_palapa_key",
    signing_salt: "3yHPJ3ty"
  )

  plug(PalapaWeb.Router)
end
