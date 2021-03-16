# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :nudge_api,
  ecto_repos: [NudgeApi.Repo]

# Configures the endpoint
config :nudge_api, NudgeApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AXDUlOKZ/uDYi0epX31X5kdnv7QZnheM+AklwwEcrRBZFd4Zbd1QhIb9UQ/TF9FJ",
  render_errors: [view: NudgeApiWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: NudgeApi.PubSub,
  live_view: [signing_salt: "7Q7wWwjw"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ex_aws,
  region: "eu-west-1",
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  json_codec: Jason

config :ex_twilio,
  account_sid: {:system, "TWILIO_ACCOUNT_SID"},
  auth_token: {:system, "TWILIO_AUTH_TOKEN"}

config :nudge_api, Oban,
  repo: NudgeApi.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [default: 10, events: 50, media: 20]

config :sentry,
  dsn: System.fetch_env!("SENTRY_DSN"),
  included_environments: [:prod],
  environment_name: Mix.env()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
