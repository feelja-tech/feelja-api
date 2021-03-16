defmodule NudgeApi.Users.Actions.GetOauthToken do
  alias NudgeApi.{Repo}
  alias NudgeApi.Users.{UserProfile}

  # Spotify
  defp request_access_token(
         oauth_endpoint,
         code,
         redirect_uri,
         authorization = {"Authorization", _auth}
       ) do
    HTTPoison.post!(
      oauth_endpoint,
      {:form,
       [
         {:grant_type, "authorization_code"},
         {:code, code},
         {:redirect_uri, redirect_uri}
       ]},
      [
        {"Content-Type", "application/x-www-form-urlencoded"},
        authorization
      ]
    )
  end

  # Others
  defp request_access_token(
         oauth_endpoint,
         code,
         redirect_uri,
         %{client: client, secret: secret}
       ) do
    HTTPoison.post!(
      oauth_endpoint,
      {:form,
       [
         {:grant_type, "authorization_code"},
         {:code, code},
         {:redirect_uri, redirect_uri},
         {:client_id, client},
         {:client_secret, secret}
       ]},
      [
        {"Content-Type", "application/x-www-form-urlencoded"}
      ]
    )
  end

  def handle!(jwt, code, redirect_uri, oauth_endpoint, authorization) do
    %{"feelja_user" => user_id} =
      NudgeApi.Users.Helpers.SessionTokenWtf.verify(
        NudgeApiWeb.Endpoint.config(:secret_key_base),
        System.fetch_env!("SESSION_SALT"),
        jwt
      )

    case request_access_token(oauth_endpoint, code, redirect_uri, authorization) do
      %HTTPoison.Response{status_code: 200, body: body} ->
        %{token_data: body}

      _ ->
        %{token_data: nil}
    end
    |> Map.merge(%{
      user_profile:
        UserProfile
        |> Repo.get_by!(%{user_id: user_id})
    })
  end
end
