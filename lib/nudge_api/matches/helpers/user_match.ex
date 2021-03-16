defmodule NudgeApi.Matches.Helpers.UserMatch do
  @behaviour NudgeApi.Matches.Helpers.UserEvent

  import Ecto.Query

  alias NudgeApi.Users.{User}
  alias NudgeApi.Repo
  alias NudgeApi.Matches.{UserMatch, Match}

  @match_expiration_minutes 10

  defp base_query(user_id) do
    UserMatch
    |> where(
      [um],
      um.user_id == ^user_id and (is_nil(um.chosen) or um.chosen) and
        (is_nil(um.unlocked_at) or
           um.unlocked_at > ^Timex.shift(Timex.now(), minutes: -@match_expiration_minutes))
    )
    |> join(:inner, [um], m in Match, on: um.match_id == m.id and is_nil(m.finalized_at))
    |> join(
      :left,
      [um, m],
      oum in UserMatch,
      on: m.id == oum.match_id and oum.user_id != ^user_id and (is_nil(oum.chosen) or oum.chosen)
    )
    |> preload([um, m, oum], match: {m, user_matches: {oum, :user}})
    |> select([um, m, oum], um)
  end

  def list_undetermined(%User{id: user_id}) do
    user_id
    |> base_query()
    |> Repo.all()
  end

  def get_undetermined!(%User{id: user_id}, %Match{id: match_id}) do
    user_id
    |> base_query()
    |> where(match_id: ^match_id)
    |> Repo.one!()
  end
end
