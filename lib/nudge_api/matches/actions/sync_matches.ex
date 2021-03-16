# def create_match(conn, %{
#       "user_id" => str_user_id,
#       "other_user_id" => str_other_user_id,
#       "location" => location
#     }) do
#   {user_id, _} = Integer.parse(str_user_id)
#   {other_user_id, _} = Integer.parse(str_other_user_id)

#   # Create match
#   %NudgeApi.Match{id: match_id} =
#     NudgeApi.Repo.insert!(%NudgeApi.Match{
#       location: %{url: location},
#       have_met: false
#     })

#   # Create user_matches
#   %NudgeApi.UserMatch{id: user_match_id} =
#     %NudgeApi.UserMatch{user_id: user_id, match_id: match_id} |> NudgeApi.Repo.insert!()

#   %NudgeApi.UserMatch{user_id: other_user_id, match_id: match_id} |> NudgeApi.Repo.insert!()

#   # Send notification
#   NudgeApi.Repo.get!(NudgeApi.User, user_id)
#   |> NudgeApi.User.send_match_notification(user_match_id)

#   json(conn, %{success: true})
# end

# Call this action when scores update or new users are added
defmodule NudgeApi.Matches.Actions.SyncMatches do
  # females can match someone up to 0.1 better score, but not lower. opposite for males
  @upper_score_delta Decimal.new("0.1")
  @lower_score_delta Decimal.new("0")

  # More than max the girl would feel too free. Less than min the girl would feel the app sucks
  @cheerleader_max Decimal.new("0.2")
  @cheerleader_min Decimal.new("0.4")

  @max_matches 4

  alias NudgeApi.{Repo, Matches}
  alias NudgeApi.Users.{User, UserProfile}
  alias NudgeApi.Matches.{UserMatch, Match}
  import Ecto.Query

  def free_straight_query(gender) do
    busy_user_ids =
      Match
      |> where(
        [m],
        not m.have_met and
          (is_nil(m.meeting_time) or
             (not is_nil(m.meeting_time) and m.meeting_time < ^Timex.now()))
      )
      |> join(:inner, [m], um in UserMatch,
        on:
          m.id == um.match_id and
            ((is_nil(um.chosen_at) and is_nil(um.cancelled_at)) or
               not is_nil(um.chosen_at))
      )
      |> join(:inner, [m, um], u in User, on: u.id == um.user_id)
      |> select([m, um, u], u.id)
      |> Repo.all()

    User
    |> where(
      [u],
      u.state not in ["banned", "disabled", "incomplete"] and u.id not in ^busy_user_ids
    )
    |> join(:inner, [u], up in UserProfile,
      on: u.id == up.user_id and up.gender == ^gender and ^gender not in up.gender_preferences
    )
  end

  defp find_match(score) do
    upper_bound = Decimal.add(score, @upper_score_delta)
    lower_bound = Decimal.sub(score, @lower_score_delta)

    result =
      free_straight_query("male")
      |> where(
        [u, up],
        up.score < ^upper_bound and up.score > ^lower_bound
      )
      |> order_by([u, up], desc: up.score)
      |> select([u, up], [u, up.score])
      |> first
      |> Repo.one()

    result
  end

  defp match_users(%User{id: user1_id}, %User{id: user2_id}) do
    {:ok, %Match{id: match_id} = match} = Matches.create_match()
    {:ok, _} = Matches.create_user_match(%{user_id: user1_id, match_id: match_id})
    {:ok, _} = Matches.create_user_match(%{user_id: user2_id, match_id: match_id})
    match
  end

  defp create_prime_candidate_matches do
    free_straight_query("female")
    |> order_by([u, up], desc: up.score)
    |> select([u, up], [u, up.score])
    |> Repo.all()
    |> Enum.reduce([], fn [female | [female_score | _]], acc ->
      case find_match(female_score) do
        nil ->
          acc

        [male | [male_score | _]] ->
          match = match_users(female, male)

          acc ++ [%{match: match, score: male_score, female: female}]
      end
    end)
  end

  defp distribute_leftovers(prime_matches, max_matches) do
    for i <- 0..max_matches,
        i > 0,
        do:
          prime_matches
          |> Enum.sort_by(
            fn x ->
              x.score
            end,
            fn y, z ->
              # desc
              Decimal.gt?(y, z)
            end
          )
          |> Enum.each(fn %{match: match, score: score} ->
            upper_bound = Decimal.sub(score, @cheerleader_max)
            lower_bound = Decimal.sub(score, @cheerleader_min)

            leftover_id =
              free_straight_query("male")
              |> where(
                [u, up],
                up.score < ^upper_bound and up.score > ^lower_bound
              )
              |> order_by([u, up], asc: up.score)
              |> select([u, up], u.id)
              |> first
              |> Repo.one()

            Matches.create_user_match(%{user_id: leftover_id, match_id: match.id})
          end)
  end

  # TODO: optimize this shit
  def handle do
    prime_candidate_matches = create_prime_candidate_matches()

    prime_candidate_matches
    |> Enum.map(fn %{match: match, score: male_score, female: _} ->
      %{match: match, score: male_score}
    end)
    |> distribute_leftovers(@max_matches)

    prime_candidate_matches
    |> Enum.each(fn %{match: _match, score: _score, female: female} ->
      Machinery.transition_to(
        female,
        NudgeApi.Fsms.UserFsm,
        :has_match
      )
    end)

    length(prime_candidate_matches)
  end
end
