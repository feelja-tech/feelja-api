defmodule NudgeApi.Matches.VideoCall do
  use Ecto.Schema
  import Ecto.Changeset

  schema "video_calls" do
    field :happens_at, :utc_datetime
    field :finalized_at, :utc_datetime

    has_many :user_video_calls, NudgeApi.Matches.UserVideoCall
    belongs_to :match, NudgeApi.Matches.Match

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(video_call, attrs) do
    video_call
    |> cast(attrs, [:happens_at, :finalized_at, :match_id])
    |> validate_required([])
  end
end
