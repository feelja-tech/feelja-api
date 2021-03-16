defmodule NudgeApi.Matches.Actions.IssueVideoCallToken do
  alias NudgeApi.Matches

  @spec handle!(%Matches.UserVideoCall{}) :: %Matches.UserVideoCall{}
  def handle!(
        %Matches.UserVideoCall{video_call_id: video_call_id, user_id: user_id} = user_video_call
      ) do
    access_token =
      ExTwilio.JWT.AccessToken.new(
        account_sid: System.fetch_env!("TWILIO_ACCOUNT_SID"),
        api_key: System.fetch_env!("TWILIO_API_KEY_SID"),
        api_secret: System.fetch_env!("TWILIO_API_KEY_SECRET"),
        identity: Integer.to_string(user_id),
        expires_in:
          case Mix.env() do
            :prod -> 600
            _ -> 84600
          end,
        grants: [
          ExTwilio.JWT.AccessToken.VideoGrant.new(room: Integer.to_string(video_call_id))
        ]
      )
      |> ExTwilio.JWT.AccessToken.to_jwt!()

    {:ok, uvc} = user_video_call |> Matches.update_user_video_call(%{access_token: access_token})

    uvc
  end
end
