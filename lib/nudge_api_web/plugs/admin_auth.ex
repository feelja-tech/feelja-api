defmodule NudgeApiWeb.Plugs.AdminAuth do
  def init(opts), do: opts

  def call(conn, _opts) do
    Plug.BasicAuth.basic_auth(conn,
      username: System.fetch_env!("AUTH_USERNAME"),
      password: System.fetch_env!("AUTH_PASSWORD"),
      realm: "nudge-api"
    )
  end
end
