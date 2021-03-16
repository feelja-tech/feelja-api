defmodule NudgeApi.Fsms.UserFsm do
  alias NudgeApi.Users.User
  alias NudgeApi.Fsms.{UserFsmLog, UserStateEnum}
  alias NudgeApi.Users.Actions.{SendSms, GenerateOtpLink}
  alias NudgeApi.{Repo, Users}

  use Machinery,
    states: UserStateEnum.values(),
    transitions: %{
      :incomplete => [:waiting_match, :disabled],
      :waiting_match => [:has_match, :disabled, :waiting_match],
      :has_match => [:in_match],
      :in_match => [:waiting_match, :waiting_video_call],
      :waiting_video_call => [:has_video_call, :disabled, :waiting_match],
      :has_video_call => [:in_video_call],
      :in_video_call => [:waiting_match, :waiting_meeting],
      :waiting_meeting => [:waiting_meeting_plan, :disabled, :waiting_match],
      :waiting_meeting_plan => [:has_meeting],
      :has_meeting => [:in_meeting],
      :in_meeting => [:waiting_match],
      :disabled => :waiting_match,
      "*" => :banned
    }

  def persist(user = %User{id: user_id, state: from_state}, to_state) do
    Repo.insert!(%UserFsmLog{
      user_id: user_id,
      from_state: from_state,
      to_state: to_state
    })

    {:ok, user} = Users.update_user(user, %{state: to_state})
    user
  end

  def before_transition(
        user = %User{id: user_id, phone_number: phone_number},
        to_state
      ) do
    Absinthe.Subscription.publish(NudgeApiWeb.Endpoint, to_state, current_user_state: user_id)

    with :has_match <- to_state do
      opt_link = GenerateOtpLink.handle!(user)

      SendSms.handle!(
        phone_number,
        "Feelja found you a new match! \n Check it out: #{opt_link}"
      )
    end

    user
  end
end
