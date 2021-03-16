defmodule NudgeApi.Fsms.UserFsmLog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_fsm_logs" do
    field :from_state, NudgeApi.Fsms.UserStateEnum
    field :to_state, NudgeApi.Fsms.UserStateEnum

    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :from_state,
      :to_state
    ])
    |> validate_required([:from_state, :to_state])
  end
end
