defmodule NudgeApiWeb.Plugs.CurrentUser do
  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = Plug.Conn.get_session(conn, "feelja_user")

    if user_id do
      NudgeApi.Repo.get(NudgeApi.Users.User, user_id)
      |> case do
        nil ->
          conn |> Plug.Conn.send_resp(401, "Unauthorized") |> Plug.Conn.halt()

        user ->
          conn
          |> Plug.Conn.assign(:current_user, user)
      end
    else
      conn |> Plug.Conn.send_resp(401, "Unauthorized") |> Plug.Conn.halt()
    end
  end
end
