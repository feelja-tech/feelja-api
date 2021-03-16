defmodule NudgeApi.Matches.Actions.UpdateEventAvailability do
  alias NudgeApi.{Matches, Repo, Users}
  alias NudgeApi.Matches.{Meeting, VideoCall, UserMeeting, UserVideoCall}
  alias NudgeApi.Fsms.UserFsm

  defp match_availabilities!(current_user_event, other_availabilities) do
    case current_user_event.availabilities
         |> MapSet.new()
         |> MapSet.intersection(MapSet.new(other_availabilities))
         |> MapSet.to_list() do
      [] ->
        raise "Availabilities are not intersecting"

      [intersecting_time | _] ->
        intersecting_time =
          if Timex.compare(intersecting_time, Timex.now(), :minutes) == 1 do
            intersecting_time
          else
            Timex.now()
          end

        changes = %{happens_at: intersecting_time}

        event =
          current_user_event
          |> case do
            %UserMeeting{} ->
              current_user_event.meeting |> Meeting.changeset(changes)

            %UserVideoCall{} ->
              current_user_event.video_call |> VideoCall.changeset(changes)
          end
          |> Repo.update!()

        case event do
          %Meeting{} -> %{meeting_id: event.id}
          %VideoCall{} -> %{video_call_id: event.id}
        end
        |> Matches.Workers.UnlockEvent.new(scheduled_at: intersecting_time)
        |> Oban.insert!()

        event
    end
  end

  defp transition_users!(current_user, other_user, state) do
    {:ok, _} =
      Machinery.transition_to(
        current_user,
        UserFsm,
        state
      )

    {:ok, _} =
      Machinery.transition_to(
        other_user,
        UserFsm,
        state
      )
  end

  def handle(
        %{current_user_event: current_user_event, current_user: current_user},
        availabilities
      ) do
    current_user_event
    |> case do
      %UserMeeting{} = current_user_event ->
        current_user_event |> UserMeeting.changeset(%{availabilities: availabilities})

      %UserVideoCall{} = current_user_event ->
        current_user_event |> UserVideoCall.changeset(%{availabilities: availabilities})
    end
    |> Repo.update!()

    current_user_event =
      current_user_event
      |> case do
        %UserVideoCall{} ->
          %VideoCall{id: current_user_event.video_call_id}

        %UserMeeting{} ->
          %Meeting{id: current_user_event.meeting_id}
      end
      |> Matches.Helpers.UserEvent.get_undetermined!(current_user)

    other_user_event =
      current_user_event
      |> case do
        %UserMeeting{} = event -> List.first(event.meeting.user_meetings)
        %UserVideoCall{} = event -> List.first(event.video_call.user_video_calls)
      end

    with false <- is_nil(other_user_event),
         [_avail | _] = other_availabilities <- other_user_event.availabilities do
      current_user_event
      |> match_availabilities!(other_availabilities)
      |> case do
        %Meeting{} ->
          {:ok, _} =
            Machinery.transition_to(
              Users.get_user!(other_user_event.user_id),
              UserFsm,
              :waiting_meeting_plan
            )

        %VideoCall{} ->
          transition_users!(
            current_user,
            Users.get_user!(other_user_event.user_id),
            :has_video_call
          )
      end
    end

    {:ok, current_user}
  end
end
