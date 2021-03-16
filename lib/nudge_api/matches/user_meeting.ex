defmodule NudgeApi.Matches.UserMeeting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_meetings" do
    field :availabilities, {:array, :utc_datetime}

    belongs_to :user, NudgeApi.Users.User
    belongs_to :meeting, NudgeApi.Matches.Meeting

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_meeting, attrs) do
    user_meeting
    |> cast(attrs, [:availabilities, :user_id, :meeting_id])
    |> validate_required([:user_id, :meeting_id])
    |> unique_constraint(:unique_user_meeting_per_meeting,
      name: :unique_user_meeting_per_meeting_index
    )
  end
end
