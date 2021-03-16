defmodule NudgeApi.Triggers.Matches.MeetingLocationUpdated do
  alias NudgeApi.{Fsms, Repo, Matches}

  @notify_user_before_minutes 30

  def handle!(meeting_id) do
    meeting =
      %Matches.Meeting{
        happens_at: happens_at
      } =
      meeting_id
      |> Matches.get_meeting!()

    meeting
    |> Repo.preload(user_meetings: :user)
    |> (fn meeting ->
          meeting.user_meetings
        end).()
    |> Enum.each(fn user_meeting ->
      {:ok, _} = Machinery.transition_to(user_meeting.user, Fsms.UserFsm, :has_meeting)
    end)

    # If the event happens before the threshold we unlock immediately
    unlock_at =
      if Timex.compare(
           happens_at,
           Timex.shift(Timex.now(), minutes: -@notify_user_before_minutes),
           :minutes
         ) == 1 do
        Timex.shift(happens_at, minutes: -@notify_user_before_minutes)
      else
        Timex.now()
      end

    %{meeting_id: meeting_id}
    |> Matches.Workers.UnlockEvent.new(scheduled_at: unlock_at)
    |> Oban.insert!()

    %{meeting_id: meeting_id}
    |> Matches.Workers.FinalizeMeeting.new(scheduled_at: Timex.shift(happens_at, minutes: 60))
    |> Oban.insert!()
  end
end
