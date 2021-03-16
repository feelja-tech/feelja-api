defmodule NudgeApiWeb.Schema.CurrentUserType do
  use Absinthe.Schema.Notation

  alias NudgeApiWeb.Resolvers.Queries

  enum(:current_user_state, values: NudgeApi.Fsms.UserStateEnum.values())

  object :current_user do
    field :id, non_null(:id)

    field :state, non_null(:current_user_state)

    field :propic_file_upload_url, :string, resolve: &Queries.CurrentUser.resolve_presigned_put/3
    field :face_file_upload_url, :string, resolve: &Queries.CurrentUser.resolve_presigned_put/3
    field :id_file_upload_url, :string, resolve: &Queries.CurrentUser.resolve_presigned_put/3

    field :matches, non_null(list_of(:match)), resolve: &Queries.Match.resolve_matches/3

    field :video_calls, non_null(list_of(:video_call)),
      resolve: &Queries.VideoCall.resolve_video_calls/3

    field :meetings, non_null(list_of(:meeting)), resolve: &Queries.Meeting.resolve_meetings/3

    field :profile, :profile,
      resolve: fn parent,
                  _args,
                  %{context: %{current_user: %{id: current_user_id}}} = resolution ->
        Queries.Profile.resolve_profile(parent, %{user_id: current_user_id}, resolution)
      end
  end
end
