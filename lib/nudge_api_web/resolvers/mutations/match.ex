defmodule NudgeApiWeb.Resolvers.Mutations.Match do
  alias NudgeApi.Matches.Match
  alias NudgeApi.Matches
  alias NudgeApi.Fsms.UserFsm

  alias NudgeApi.Matches.Helpers

  def finalize_match(
        _parent,
        %{
          match_id: match_id,
          chosen_user_id: chosen_user_id,
          availabilities: availabilities
        },
        %{
          context: %{current_user: current_user}
        }
      ) do
    user_match =
      current_user
      |> Matches.Actions.FinalizeEvent.handle(
        %Match{id: match_id},
        chosen_user_id,
        availabilities
      )

    {:ok, user_match}
  end

  def unlock_match(
        _parent,
        %{match_id: match_id},
        %{
          context: %{current_user: current_user}
        }
      ) do
    {:ok, _user} =
      Machinery.transition_to(
        current_user,
        UserFsm,
        :in_match
      )

    %Matches.UserMatch{match: %Matches.Match{user_matches: other_user_matches}} =
      user_match =
      current_user
      |> Helpers.UserMatch.get_undetermined!(%Match{id: match_id})

    other_user_id =
      other_user_matches
      |> Enum.map(fn um ->
        um.user_id
      end)
      |> List.first()

    %{current_user_id: current_user.id, other_user_id: other_user_id, match_id: match_id}
    |> Matches.Workers.TimeoutMatch.new(scheduled_at: Timex.shift(Timex.now(), minutes: 10))
    |> Oban.insert!()

    user_match |> Matches.update_user_match(%{unlocked_at: Timex.now()})
  end
end
