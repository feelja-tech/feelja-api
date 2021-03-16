defmodule NudgeApiWeb.Schema.MeetingType do
  use Absinthe.Schema.Notation

  alias NudgeApiWeb.Resolvers.Queries

  object :meeting do
    field :id, :id, resolve: fn parent, _, _ -> {:ok, parent.meeting_id} end

    field :happens_at, :datetime, resolve: fn parent, _, _ -> {:ok, parent.meeting.happens_at} end
    field :location, :json, resolve: fn parent, _, _ -> {:ok, parent.meeting.location} end

    field :profiles, list_of(:profile), resolve: &Queries.Meeting.resolve_meeting_profiles/3
  end
end
