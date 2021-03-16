defmodule NudgeApiWeb.Endpoint do
  use Sentry.PlugCapture

  use Phoenix.Endpoint, otp_app: :nudge_api

  use Absinthe.Phoenix.Endpoint

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "feelja_user",
    signing_salt: System.fetch_env!("SESSION_SALT"),
    max_age: 86400 * 30,
    domain:
      case Mix.env() do
        :prod -> ".feelja.com"
        _ -> "192.168.1.4"
      end,
    path: "/",
    secure: Mix.env() == :prod,
    same_site: "Lax",
    http_only: false
  ]

  socket("/socket", NudgeApiWeb.UserSocket,
    websocket: true,
    longpoll: false
  )

  socket("/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]])

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :nudge_api,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)
  )

  plug(Plug.Static,
    at: "/admin",
    from: :nudge_api,
    gzip: false,
    only: ~w(dashboard.html)
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket("/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket)
    plug(Phoenix.LiveReloader)
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :nudge_api)
  end

  plug(Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"
  )

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Sentry.PlugContext)

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(CORSPlug, origin: [System.get_env("FRONTEND_URL"), System.get_env("API_URL")])
  plug(NudgeApiWeb.Router)
end
