defmodule NudgeApiWeb.Resolvers.Queries.Meeting do
  import Ecto.Query

  alias NudgeApi.Users.{UserProfile}
  alias NudgeApi.Matches.{Helpers, Meeting}
  alias NudgeApi.{Repo}

  def resolve_meeting_profiles(
        %{meeting_id: meeting_id},
        _args,
        %{
          context: %{current_user: current_user}
        }
      ) do
    user_ids =
      current_user
      |> Helpers.UserMeeting.get_undetermined!(%Meeting{id: meeting_id})
      |> (fn um ->
            um.meeting.user_meetings
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

  def resolve_meetings(_parent, _args, %{
        context: %{current_user: current_user}
      }) do
    result = current_user |> Helpers.UserMeeting.list_undetermined()

    {:ok, result}
  end
end
