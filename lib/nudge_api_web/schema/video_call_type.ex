defmodule NudgeApiWeb.Schema.VideoCallType do
  use Absinthe.Schema.Notation

  import Ecto.Query

  alias NudgeApi.Repo
  alias NudgeApi.Matches.{UserMeeting, Meeting}

  alias NudgeApiWeb.Resolvers.Queries

  object :video_call do
    field :id, :id, resolve: fn parent, _, _ -> {:ok, parent.video_call_id} end
    field :initiator, :boolean

    field :happens_at, :datetime,
      resolve: fn parent, _, _ -> {:ok, parent.video_call.happens_at} end

    field :availabilities, list_of(:datetime),
      resolve: fn user_video_call, _, _ ->
        Meeting
        |> where([m], m.video_call_id == ^user_video_call.video_call_id)
        |> join(:inner, [m], um in UserMeeting,
          on: um.user_id != ^user_video_call.user_id and um.meeting_id == m.id
        )
        |> select([m, um], um)
        |> Repo.one()
        |> case do
          nil -> {:ok, nil}
          other_meeting -> {:ok, other_meeting.availabilities}
        end
      end

    field :access_token, :string
    field :profiles, list_of(:profile), resolve: &Queries.VideoCall.resolve_video_call_profiles/3
  end
end
