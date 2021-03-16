defmodule NudgeApi.Users.OAuth.InstagramHandler do
  alias NudgeApi.Users.Actions.GetOauthToken
  alias NudgeApi.Users

  @behaviour NudgeApi.Users.OAuth.OAuthHandler

  @oauth_endpoint "https://api.instagram.com/oauth/access_token"
  @api_endpoint "https://graph.instagram.com/access_token"

  # TODO: query API before token expires
  # https://developers.facebook.com/docs/instagram-api/reference

  defp get_long_lived_token(%{"access_token" => short_lived_token}) do
    secret = System.fetch_env!("INSTAGRAM_SECRET")

    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!(
        "#{@api_endpoint}?grant_type=ig_exchange_token&client_secret=#{secret}&access_token=#{
          short_lived_token
        }"
      )

    body |> Poison.Parser.parse!()
  end

  def get_access_token!(%{code: code, jwt: jwt}) do
    GetOauthToken.handle!(
      jwt,
      code,
      System.fetch_env!("API_URL") <> "/api/oauth/instagram",
      @oauth_endpoint,
      %{
        client: System.fetch_env!("INSTAGRAM_CLIENT"),
        secret: System.fetch_env!("INSTAGRAM_SECRET")
      }
    )
  end

  def process_access_token!(%{
        user_profile: user_profile,
        token_data: token_data
      }) do
    with token_data when not is_nil(token_data) <- token_data do
      access_token_metadata = token_data |> Poison.Parser.parse!() |> get_long_lived_token()

      {access_token, access_token_metadata} =
        access_token_metadata
        |> Map.pop("access_token")

      {expires_in, access_token_metadata} =
        access_token_metadata
        |> Map.pop("expires_in")

      {:ok, _struct} =
        Users.create_social_account(%{
          user_profile_id: user_profile.id,
          account_type: "instagram",
          access_token: access_token,
          access_token_metadata: access_token_metadata,
          expires_at:
            Timex.now()
            |> Timex.add(Timex.Duration.from_seconds(expires_in))
        })
    end
  end
end
