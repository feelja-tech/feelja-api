defmodule NudgeApiWeb.Schema do
  use Absinthe.Schema

  alias NudgeApiWeb.Resolvers.{Mutations}

  import_types(Absinthe.Type.Custom)

  import_types(NudgeApiWeb.Schema.CurrentUserType)
  import_types(NudgeApiWeb.Schema.ProfileType)
  import_types(NudgeApiWeb.Schema.MatchType)
  import_types(NudgeApiWeb.Schema.MeetingType)
  import_types(NudgeApiWeb.Schema.VideoCallType)
  import_types(NudgeApiWeb.Schema.JsonType)

  query do
    @desc "Get logged in user"
    field :current_user, non_null(:current_user),
      resolve: fn _parent,
                  _args,
                  %{
                    context: %{current_user: current_user}
                  } ->
        {:ok, current_user}
      end
  end

  mutation do
    @desc "Update current user profile"
    field :update_current_profile, :profile do
      arg(:name, non_null(:string))
      arg(:age, non_null(:integer))
      arg(:height, non_null(:integer))
      arg(:politic_preferences, non_null(list_of(:string)))
      arg(:religious_preferences, non_null(list_of(:string)))
      arg(:location, :json)

      resolve(&Mutations.Profile.update_profile/3)
    end

    @desc "Exclude user from getting more matches"
    field :disable_user, :current_user do
      resolve(&Mutations.CurrentUser.disable_user/3)
    end

    @desc "Unlock matches, start timer"
    field :unlock_match, :match do
      arg(:match_id, non_null(:id))
      resolve(&Mutations.Match.unlock_match/3)
    end

    @desc "Accept or reject a match. Set chosen_user_id to nil to reject"
    field :finalize_match, :match do
      arg(:match_id, non_null(:id))
      arg(:chosen_user_id, :id)
      arg(:availabilities, non_null(list_of(:datetime)))
      resolve(&Mutations.Match.finalize_match/3)
    end

    @desc "Accept or reject a video_call. Set chosen_user_id to nil to reject"
    field :finalize_video_call, :video_call do
      arg(:video_call_id, non_null(:id))
      arg(:chosen_user_id, :id)
      arg(:availabilities, non_null(list_of(:datetime)))
      resolve(&Mutations.VideoCall.finalize_video_call/3)
    end
  end

  subscription do
    @desc "Subscribe to user.state updates"
    field :current_user_state, :current_user_state do
      config(fn _args, %{context: %{current_user: %{id: user_id}}} ->
        {:ok, topic: user_id}
      end)
    end
  end
end
