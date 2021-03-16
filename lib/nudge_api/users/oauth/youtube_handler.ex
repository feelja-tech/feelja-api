defmodule NudgeApi.Users.OAuth.YoutubeHandler do
  alias NudgeApi.Users.Actions.GetOauthToken
  alias NudgeApi.Users

  @behaviour NudgeApi.Users.OAuth.OAuthHandler

  @oauth_endpoint "https://oauth2.googleapis.com/token"
  @api_endpoint "https://www.googleapis.com/youtube/v3/subscriptions"

  # API ref https://developers.google.com/youtube/v3/docs/subscriptions/list

  defp get_user_info(%{"access_token" => access_token}) do
    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!(
        "#{@api_endpoint}?access_token=#{access_token}&mine=true&maxResults=50&part=snippet"
      )

    body |> Poison.Parser.parse!()
  end

  def process_access_token!(%{
        user_profile: user_profile,
        token_data: token_data
      }) do
    with token_data when not is_nil(token_data) <- token_data do
      access_token_metadata = token_data |> Poison.Parser.parse!()

      user_info = access_token_metadata |> get_user_info()

      {access_token, access_token_metadata} =
        access_token_metadata
        |> Map.pop("access_token")

      {expires_in, access_token_metadata} =
        access_token_metadata
        |> Map.pop("expires_in")

      {:ok, _} =
        Users.create_social_account(%{
          user_profile_id: user_profile.id,
          account_type: "youtube",
          access_token: access_token,
          access_token_metadata: access_token_metadata,
          expires_at:
            Timex.now()
            |> Timex.add(Timex.Duration.from_seconds(expires_in)),
          data: user_info
        })
    end
  end

  def get_access_token!(%{code: code, jwt: jwt}) do
    GetOauthToken.handle!(
      jwt,
      code,
      System.fetch_env!("API_URL") <> "/api/oauth/youtube",
      @oauth_endpoint,
      %{
        client: System.fetch_env!("GOOGLE_CLIENT"),
        secret: System.fetch_env!("GOOGLE_SECRET")
      }
    )
  end
end
