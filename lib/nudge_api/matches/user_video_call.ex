defmodule NudgeApi.Matches.UserVideoCall do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_video_calls" do
    field :availabilities, {:array, :utc_datetime}
    field :access_token, :string
    field :initiator, :boolean
    field :chosen, :boolean

    belongs_to :user, NudgeApi.Users.User
    belongs_to :video_call, NudgeApi.Matches.VideoCall

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_video_call, attrs) do
    user_video_call
    |> cast(attrs, [:availabilities, :user_id, :video_call_id, :access_token, :chosen, :initiator])
    |> validate_required([:user_id, :video_call_id])
    |> unique_constraint(:unique_user_video_call_per_video_call,
      name: :unique_user_video_call_per_video_call_index
    )
    |> unique_constraint(:access_token)
  end
end
