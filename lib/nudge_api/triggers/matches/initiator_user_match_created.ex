defmodule NudgeApi.Triggers.Matches.InitiatorUserMatchCreated do
  def handle!(user_id) do
    {:ok, _} =
      Machinery.transition_to(
        NudgeApi.Users.get_user!(user_id),
        NudgeApi.Fsms.UserFsm,
        :has_match
      )
  end
end
