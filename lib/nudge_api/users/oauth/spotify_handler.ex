defmodule NudgeApi.Users.OAuth.SpotifyHandler do
  alias NudgeApi.Users.Actions.GetOauthToken
  alias NudgeApi.Users

  @behaviour NudgeApi.Users.OAuth.OAuthHandler

  @oauth_endpoint "https://accounts.spotify.com/api/token"
  @api_endpoint "https://api.spotify.com/v1/me/top/artists"

  # API ref https://developer.spotify.com/documentation/web-api/reference-beta/

  defp get_user_info(%{"access_token" => access_token}) do
    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!(@api_endpoint, [
        {
          "Authorization",
          "Bearer #{access_token}"
        }
      ])

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
          account_type: "spotify",
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
    authorization =
      {"Authorization",
       "Basic " <>
         Base.encode64(
           System.fetch_env!("SPOTIFY_CLIENT") <> ":" <> System.fetch_env!("SPOTIFY_SECRET")
         )}

    GetOauthToken.handle!(
      jwt,
      code,
      System.fetch_env!("API_URL") <> "/api/oauth/spotify",
      @oauth_endpoint,
      authorization
    )
  end
end
