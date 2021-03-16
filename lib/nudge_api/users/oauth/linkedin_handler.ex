defmodule NudgeApi.Users.OAuth.LinkedinHandler do
  alias NudgeApi.Users.Actions.GetOauthToken
  alias NudgeApi.Users

  @behaviour NudgeApi.Users.OAuth.OAuthHandler

  @oauth_endpoint "https://www.linkedin.com/oauth/v2/accessToken"
  @api_endpoint "https://api.linkedin.com/v2/me"

  defp get_user_info(%{"access_token" => access_token}) do
    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!("#{@api_endpoint}?oauth2_access_token=#{access_token}")

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
          account_type: "linkedin",
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
      System.fetch_env!("API_URL") <> "/api/oauth/linkedin",
      @oauth_endpoint,
      %{
        client: System.fetch_env!("LINKEDIN_CLIENT"),
        secret: System.fetch_env!("LINKEDIN_SECRET")
      }
    )
  end
end
