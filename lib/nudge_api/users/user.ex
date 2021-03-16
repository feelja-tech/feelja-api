defmodule NudgeApi.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :phone_number, :string
    field :sms_code, :string
    field :state, NudgeApi.Fsms.UserStateEnum
    field :otp, :string
    field :otp_expires_at, :utc_datetime

    has_one :user_profile, NudgeApi.Users.UserProfile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :phone_number,
      :sms_code,
      :state,
      :otp_expires_at,
      :otp
    ])
    |> validate_required([:phone_number])
    |> unique_constraint(:phone_number)
  end
end
