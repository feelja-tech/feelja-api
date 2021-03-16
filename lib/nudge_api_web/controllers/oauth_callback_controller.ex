defmodule NudgeApiWeb.OAuthCallbackController do
  use NudgeApiWeb, :controller

  alias NudgeApi.Users.OAuth.{
    OAuthHandler,
    LinkedinHandler,
    InstagramHandler,
    SpotifyHandler,
    YoutubeHandler
  }

  defp send_response(conn, iframe) do
    if iframe do
      html(conn, """
       <html>
         <head>
            <title>Passing a Messenger</title>
         </head>
         <body>
           <script>
            window.close('','_parent','')
           </script>
         </body>
       </html>
      """)
    else
      redirect(conn, external: System.fetch_env!("FRONTEND_URL") <> "/signup/social_networks")
    end
  end

  def oauth_callback(conn, %{"code" => code, "state" => state}) do
    %{"jwt" => jwt, "iframe" => iframe} = state |> Poison.Parser.parse!()

    implementation =
      conn
      |> current_path(%{})
      |> case do
        "/api/oauth/instagram" -> InstagramHandler
        "/api/oauth/linkedin" -> LinkedinHandler
        "/api/oauth/youtube" -> YoutubeHandler
        "/api/oauth/spotify" -> SpotifyHandler
      end

    params =
      implementation
      |> OAuthHandler.get_access_token!(%{jwt: jwt, code: code})

    implementation
    |> OAuthHandler.process_access_token!(params)

    send_response(conn, iframe)
  end

  def oauth_callback(conn, %{"error" => _error, "state" => state}) do
    %{"iframe" => iframe} = state |> Poison.Parser.parse!()

    send_response(conn, iframe)
  end
end
