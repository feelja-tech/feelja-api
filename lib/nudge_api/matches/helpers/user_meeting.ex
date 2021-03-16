defmodule NudgeApi.Matches.Helpers.UserMeeting do
  @behaviour NudgeApi.Matches.Helpers.UserEvent

  import Ecto.Query

  alias NudgeApi.Users.{User}
  alias NudgeApi.Repo
  alias NudgeApi.Matches.{UserMeeting, Meeting}

  def base_query(user_id) do
    UserMeeting
    |> where(
      [um],
      um.user_id == ^user_id
    )
    |> join(
      :inner,
      [um],
      m in Meeting,
      on: m.id == um.meeting_id and is_nil(m.finalized_at)
    )
    |> join(
      :left,
      [um, m],
      oum in UserMeeting,
      on: m.id == oum.meeting_id and oum.user_id != ^user_id
    )
    |> preload([um, m, oum], meeting: {m, user_meetings: {oum, :user}})
    |> select([um, m, oum], um)
  end

  def list_undetermined(%User{id: user_id}) do
    user_id
    |> base_query()
    |> Repo.all()
  end

  def get_undetermined!(%User{id: user_id}, %Meeting{id: meeting_id}) do
    user_id
    |> base_query()
    |> where(meeting_id: ^meeting_id)
    |> Repo.one!()
  end
end
