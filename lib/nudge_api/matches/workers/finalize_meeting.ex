defmodule NudgeApi.Matches.Workers.FinalizeMeeting do
  use Oban.Worker, queue: :events, unique: [period: :infinity], max_attempts: 3

  alias NudgeApi.{Fsms, Matches, Repo}

  @impl Oban.Worker
  def perform(%Oban.Job{
        args: %{"meeting_id" => meeting_id}
      }) do
    {:ok, meeting} =
      Matches.get_meeting!(meeting_id)
      |> Repo.preload(user_meetings: :user)
      |> Matches.update_meeting(%{finalized_at: Timex.now()})

    meeting.user_meetings
    |> Enum.map(fn user_meeting -> user_meeting.user end)
    |> Enum.each(fn user ->
      {:ok, _} =
        Machinery.transition_to(
          user,
          Fsms.UserFsm,
          :waiting_match
        )
    end)

    :ok
  end
end
