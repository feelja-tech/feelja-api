defmodule NudgeApiWeb.Resolvers.Queries.VideoCall do
  import Ecto.Query

  alias NudgeApi.Users.{UserProfile}
  alias NudgeApi.Matches.{Helpers, VideoCall}
  alias NudgeApi.{Repo}

  def resolve_video_call_profiles(
        %{video_call_id: video_call_id},
        _args,
        %{
          context: %{current_user: current_user}
        }
      ) do
    user_ids =
      current_user
      |> Helpers.UserVideoCall.get_undetermined!(%VideoCall{id: video_call_id})
      |> (fn um ->
            um.video_call.user_video_calls
          end).()
      |> Enum.map(fn um ->
        um.user_id
      end)

    result =
      UserProfile
      |> where([up], up.user_id in ^user_ids)
      |> preload(:social_accounts)
      |> Repo.all()

    {:ok, result}
  end

  def resolve_video_calls(_parent, _args, %{
        context: %{current_user: current_user}
      }) do
    result = current_user |> Helpers.UserVideoCall.list_undetermined()

    {:ok, result}
  end
end
