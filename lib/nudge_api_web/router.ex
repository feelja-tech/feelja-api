defmodule NudgeApiWeb.Router do
  use NudgeApiWeb, :router

  ### Administration ###

  def graphiql_headers do
    %{"X-CSRF-Token" => Plug.CSRFProtection.get_csrf_token()}
  end

  import Phoenix.LiveDashboard.Router

  pipeline :browser_admin do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug NudgeApiWeb.Plugs.AdminAuth
  end

  scope "/admin" do
    pipe_through :browser_admin

    live_dashboard "/phoenix_dashboard",
      metrics: NudgeApiWeb.Telemetry,
      ecto_repos: [NudgeApi.Repo]

    forward "/graphiql",
            Absinthe.Plug.GraphiQL,
            schema: NudgeApiWeb.Schema,
            socket: NudgeApiWeb.UserSocket,
            default_headers: {__MODULE__, :graphiql_headers},
            default_url: "/api/graphql"
  end

  ### Customers ###

  pipeline :graphql do
    plug :fetch_session
    plug NudgeApiWeb.Plugs.CurrentUser
    plug NudgeApiWeb.Context
  end

  scope "/api" do
    pipe_through [:graphql]

    forward "/graphql", Absinthe.Plug, schema: NudgeApiWeb.Schema
  end

  pipeline :rest do
    plug :accepts, ["json"]
  end

  scope "/api", NudgeApiWeb do
    pipe_through [:rest]

    post "/login", SessionController, :login
    post "/login_2fa", SessionController, :login_2fa
    get "/login_otp", SessionController, :login_otp

    get "/oauth/spotify", OAuthCallbackController, :oauth_callback
    get "/oauth/instagram", OAuthCallbackController, :oauth_callback
    get "/oauth/youtube", OAuthCallbackController, :oauth_callback
    get "/oauth/linkedin", OAuthCallbackController, :oauth_callback
  end
end
