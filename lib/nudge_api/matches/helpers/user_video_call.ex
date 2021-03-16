defmodule NudgeApi.Matches.Helpers.UserVideoCall do
  @behaviour NudgeApi.Matches.Helpers.UserEvent

  import Ecto.Query

  alias NudgeApi.Users.{User}
  alias NudgeApi.Repo
  alias NudgeApi.Matches.{UserVideoCall, VideoCall}

  def base_query(user_id) do
    UserVideoCall
    |> where(
      [uvc],
      uvc.user_id == ^user_id and (is_nil(uvc.chosen) or uvc.chosen)
    )
    |> join(
      :inner,
      [uvc],
      vc in VideoCall,
      on: vc.id == uvc.video_call_id and is_nil(vc.finalized_at)
    )
    |> join(
      :left,
      [uvc, vc],
      ouvc in UserVideoCall,
      on:
        vc.id == ouvc.video_call_id and ouvc.user_id != ^user_id and
          (is_nil(ouvc.chosen) or ouvc.chosen)
    )
    |> preload([uvc, vc, ouvc], video_call: {vc, user_video_calls: {ouvc, :user}})
    |> select([uvc, vc, ouvc], uvc)
  end

  def list_undetermined(%User{id: user_id}) do
    user_id
    |> base_query()
    |> Repo.all()
  end

  def get_undetermined!(%User{id: user_id}, %VideoCall{id: video_call_id}) do
    user_id
    |> base_query()
    |> where(video_call_id: ^video_call_id)
    |> Repo.one!()
  end
end
