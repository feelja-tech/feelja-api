defmodule NudgeApiWeb.AdminController do
  use NudgeApiWeb, :controller

  plug NudgeApiWeb.Plugs.AdminAuth

  # def sync_matches(conn, _params) do
  #   new_matches_count = NudgeApi.Matches.Actions.SyncMatches.handle()
  #   json(conn, %{success: true, new_matches_count: new_matches_count})
  # end

  @spec create_match(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create_match(conn, %{"main_user_id" => main_user_id, "user_ids" => user_ids}) do
    user_ids
    |> Poison.Parser.parse!(%{keys: :atoms})
    |> NudgeApi.Matches.Actions.CreateMatch.handle!(main_user_id)

    json(conn, %{success: true})
  end
end
