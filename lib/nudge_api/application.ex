defmodule NudgeApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      NudgeApi.Repo,
      # Start the Telemetry supervisor
      NudgeApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: NudgeApi.PubSub},
      # Start the Endpoint (http/https)
      NudgeApiWeb.Endpoint,
      # Start a worker by calling: NudgeApi.Worker.start_link(arg)
      # {NudgeApi.Worker, arg}
      {Absinthe.Subscription, NudgeApiWeb.Endpoint},
      {Oban, oban_config()},
      # Postgres triggers handler
      {NudgeApi.Triggers.DatabaseListener, "table_changes"}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: NudgeApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    NudgeApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Conditionally disable queues or plugins here.
  defp oban_config do
    Application.get_env(:nudge_api, Oban)
  end
end
