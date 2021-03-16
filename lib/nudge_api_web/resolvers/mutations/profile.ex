defmodule NudgeApiWeb.Resolvers.Mutations.Profile do
  alias NudgeApi.Users.{UserProfile}
  alias NudgeApi.Fsms.UserFsm
  alias NudgeApi.{Repo, Users}

  def update_profile(_parent, args, %{context: %{current_user: current_user}}) do
    {:ok, _user} =
      Machinery.transition_to(
        current_user,
        UserFsm,
        :waiting_match
      )

    Users.update_user_profile(
      Repo.get_by(UserProfile, user_id: current_user.id),
      args
    )
  end
end
