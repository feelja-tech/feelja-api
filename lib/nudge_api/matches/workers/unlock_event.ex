defmodule NudgeApi.Matches.Workers.UnlockEvent do
  use Oban.Worker, queue: :events, unique: [period: :infinity], max_attempts: 3

  import Ecto.Query

  alias NudgeApi.{Repo, Matches, Users, Fsms}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"meeting_id" => meeting_id}}) do
    Matches.UserMeeting
    |> where(meeting_id: ^meeting_id)
    |> Repo.all()
    |> Enum.each(fn %{user_id: user_id} ->
      {:ok, _} =
        Machinery.transition_to(
          Users.get_user!(user_id),
          Fsms.UserFsm,
          :in_meeting
        )
    end)

    :ok
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"video_call_id" => video_call_id}}) do
    Matches.UserVideoCall
    |> where(video_call_id: ^video_call_id)
    |> Repo.all()
    |> Enum.each(fn %{user_id: user_id} = user_video_call ->
      user_video_call
      |> Matches.Actions.IssueVideoCallToken.handle!()

      {:ok, _} =
        Machinery.transition_to(
          Users.get_user!(user_id),
          Fsms.UserFsm,
          :in_video_call
        )
    end)

    :ok
  end
end
