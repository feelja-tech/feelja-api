defmodule NudgeApiWeb.Resolvers.Mutations.VideoCall do
  alias NudgeApi.{Matches}
  alias NudgeApi.Matches.VideoCall

  def finalize_video_call(
        _parent,
        %{
          video_call_id: video_call_id,
          chosen_user_id: chosen_user_id,
          availabilities: availabilities
        },
        %{
          context: %{current_user: current_user}
        }
      ) do
    user_video_call =
      current_user
      |> Matches.Actions.FinalizeEvent.handle(
        %VideoCall{id: video_call_id},
        chosen_user_id,
        availabilities
      )

    {:ok, user_video_call}
  end
end
