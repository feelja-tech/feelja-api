defmodule NudgeApi.Matches.Meeting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meetings" do
    field :finalized_at, :utc_datetime
    field :location, :map
    field :happens_at, :utc_datetime

    belongs_to :video_call, NudgeApi.Matches.VideoCall
    has_many :user_meetings, NudgeApi.Matches.UserMeeting

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(meeting, attrs) do
    meeting
    |> cast(attrs, [:happens_at, :location, :finalized_at, :video_call_id])
    |> validate_required([])
  end
end
