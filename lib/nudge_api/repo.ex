defmodule NudgeApi.Repo do
  use Ecto.Repo,
    otp_app: :nudge_api,
    adapter: Ecto.Adapters.Postgres
end
