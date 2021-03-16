defmodule NudgeApi.Matches.Actions.FinalizeEvent do
  alias NudgeApi.{Repo, Users, Matches}
  alias NudgeApi.Matches.{Helpers, Actions}
  alias NudgeApi.Matches.{UserMatch, UserVideoCall, VideoCall, Meeting, Match}
  alias NudgeApi.Fsms.UserFsm

  defp handle_chosen(current_user, current_user_event, chosen_user_id) do
    chosen_user_id = String.to_integer(chosen_user_id)

    # Set other user to chosen
    current_user_event
    |> case do
      %UserMatch{} ->
        current_user_event.match.user_matches

      %UserVideoCall{} ->
        current_user_event.video_call.user_video_calls
    end
    |> Enum.each(fn user_event ->
      user_event
      |> case do
        %UserMatch{} -> UserMatch
        %UserVideoCall{} -> UserVideoCall
      end
      |> (fn module ->
            user_event |> module.changeset(%{chosen: user_event.user_id == chosen_user_id})
          end).()
      |> Repo.update!()
    end)

    {:ok, current_user} =
      Machinery.transition_to(
        current_user,
        UserFsm,
        case current_user_event do
          %UserMatch{} ->
            :waiting_video_call

          %UserVideoCall{initiator: initiator} ->
            if initiator do
              :waiting_meeting
            else
              :waiting_meeting_plan
            end
        end
      )

    next_event =
      if current_user_event.initiator do
        # Notify other user
        {:ok, _user} =
          Machinery.transition_to(
            Users.get_user!(chosen_user_id),
            UserFsm,
            case current_user_event do
              %UserMatch{} -> :has_match
              %UserVideoCall{} -> :waiting_meeting
            end
          )

        # Create next event
        {:ok, event} =
          case current_user_event do
            %UserMatch{} ->
              Matches.create_video_call(%{match_id: current_user_event.match_id})

            %UserVideoCall{} ->
              Matches.create_meeting(%{video_call_id: current_user_event.video_call_id})
          end

        event
      else
        # Finalize current event
        changes = %{finalized_at: Timex.now()}

        current_user_event
        |> case do
          %UserMatch{} ->
            current_user_event.match |> Match.changeset(changes)

          %UserVideoCall{} ->
            current_user_event.video_call |> VideoCall.changeset(changes)
        end
        |> Repo.update!()

        # Get previously created next event
        current_user_event
        |> case do
          %UserMatch{} ->
            Repo.get_by!(VideoCall, match_id: current_user_event.match_id)

          %UserVideoCall{} ->
            Repo.get_by!(Meeting, video_call_id: current_user_event.video_call_id)
        end
      end

    # Link user to next event
    {:ok, next_user_event} =
      next_event
      |> case do
        %VideoCall{} ->
          Matches.create_user_video_call(%{
            user_id: current_user.id,
            video_call_id: next_event.id,
            initiator: current_user_event.initiator
          })

        %Meeting{} ->
          Matches.create_user_meeting(%{user_id: current_user.id, meeting_id: next_event.id})
      end

    %{current_user_event: next_user_event, current_user: current_user}
  end

  defp handle_rejected(current_user, current_user_event) do
    current_user_event
    |> case do
      %UserMatch{} -> current_user_event.match.user_matches
      %UserVideoCall{} -> current_user_event.video_call.user_video_calls
    end
    |> Enum.each(fn user_event ->
      case user_event do
        %UserMatch{} -> user_event |> UserMatch.changeset(%{chosen: false})
        %UserVideoCall{} -> user_event |> UserVideoCall.changeset(%{chosen: false})
      end
      |> Repo.update!()
    end)

    current_user_event
    |> case do
      %UserMatch{} ->
        current_user_event.match |> Match.changeset(%{finalized_at: Timex.now()})

      %UserVideoCall{} ->
        current_user_event.video_call |> VideoCall.changeset(%{finalized_at: Timex.now()})
    end
    |> Repo.update!()

    # Send back other user
    # TODO refactor, different logic for event type
    {:ok, _user} =
      current_user_event
      |> case do
        %UserMatch{} -> current_user_event.match.user_matches
        %UserVideoCall{} -> current_user_event.video_call.user_video_calls
      end
      |> (fn x -> List.first(x).user end).()
      |> Machinery.transition_to(
        UserFsm,
        :waiting_match
      )

    {:ok, _user} =
      Machinery.transition_to(
        current_user,
        UserFsm,
        :waiting_match
      )
  end

  def handle(current_user, event, chosen_user_id, availabilities) do
    current_user_event =
      event
      |> Helpers.UserEvent.get_undetermined!(current_user)

    case chosen_user_id do
      nil ->
        current_user
        |> handle_rejected(current_user_event)

      _ ->
        current_user
        |> handle_chosen(current_user_event, chosen_user_id)
        |> Actions.UpdateEventAvailability.handle(availabilities)
    end

    current_user_event
  end
end
