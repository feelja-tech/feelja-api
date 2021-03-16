defmodule NudgeApiWeb.Schema.MatchType do
  use Absinthe.Schema.Notation

  import Ecto.Query

  alias NudgeApi.Repo
  alias NudgeApi.Matches.{UserVideoCall, VideoCall}
  alias NudgeApiWeb.Resolvers.Queries

  object :match do
    field :id, :id, resolve: fn parent, _, _ -> {:ok, parent.match_id} end

    field :initiator, :boolean
    field :unlocked_at, :datetime

    field :availabilities, list_of(:datetime),
      resolve: fn user_match, _, _ ->
        VideoCall
        |> where([vc], vc.match_id == ^user_match.match_id)
        |> join(:inner, [vc], uvc in UserVideoCall,
          on: uvc.user_id != ^user_match.user_id and uvc.video_call_id == vc.id
        )
        |> select([vc, uvc], uvc)
        |> Repo.one()
        |> case do
          nil -> {:ok, nil}
          other_video_call -> {:ok, other_video_call.availabilities}
        end
      end

    field :profiles, list_of(:profile), resolve: &Queries.Match.resolve_match_profiles/3
  end
end
