defmodule NudgeApiWeb.Resolvers.Queries.Match do
  import Ecto.Query

  alias NudgeApi.Users.{UserProfile}
  alias NudgeApi.Matches.{Helpers, Match}
  alias NudgeApi.{Repo}

  def resolve_match_profiles(
        %{match_id: match_id},
        _args,
        %{
          context: %{current_user: current_user}
        }
      ) do
    user_ids =
      current_user
      |> Helpers.UserMatch.get_undetermined!(%Match{id: match_id})
      |> (fn um ->
            um.match.user_matches
          end).()
      |> Enum.map(fn um ->
        um.user_id
      end)

    result =
      UserProfile
      |> where([up], up.user_id in ^user_ids)
      |> preload(:social_accounts)
      |> Repo.all()

    {:ok, result}
  end

  def resolve_matches(_parent, _args, %{
        context: %{current_user: current_user}
      }) do
    result = current_user |> Helpers.UserMatch.list_undetermined()

    {:ok, result}
  end
end
