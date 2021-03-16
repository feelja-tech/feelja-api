defmodule NudgeApi.Matches.Workers.TimeoutMatch do
  use Oban.Worker, queue: :events, unique: [period: :infinity], max_attempts: 3

  alias NudgeApi.{Users, Fsms, Matches}

  defp finalize_match(match_id) do
    {:ok, _} =
      Matches.get_match!(match_id)
      |> Matches.update_match(%{
        finalized_at: Timex.now()
      })
  end

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{
          "current_user_id" => current_user_id,
          "other_user_id" => other_user_id,
          "match_id" => match_id
        }
      }) do
    # Only has effect if user in active state

    current_user = Users.get_user!(current_user_id)

    with :in_match <- current_user.state do
      finalize_match(match_id)

      {:ok, _} =
        Machinery.transition_to(
          current_user,
          Fsms.UserFsm,
          :waiting_match
        )
    end

    other_user = Users.get_user!(other_user_id)

    with :waiting_video_call <- other_user.state do
      finalize_match(match_id)

      {:ok, _} =
        Machinery.transition_to(
          other_user,
          Fsms.UserFsm,
          :waiting_match
        )
    end

    :ok
  end
end
