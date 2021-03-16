defmodule NudgeApiWeb.Resolvers.Mutations.CurrentUser do
  alias NudgeApi.Fsms.UserFsm

  def disable_user(
        _parent,
        _args,
        %{
          context: %{current_user: current_user}
        }
      ) do
    Machinery.transition_to(
      current_user,
      UserFsm,
      :disabled
    )
  end
end
