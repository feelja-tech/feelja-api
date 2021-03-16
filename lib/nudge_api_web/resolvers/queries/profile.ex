defmodule NudgeApiWeb.Resolvers.Queries.Profile do
  alias NudgeApi.Users.{UserFile, UserProfile}
  alias NudgeApi.{Repo}
  alias NudgeApi.Users.Actions.CreatePresignedUrl

  import Ecto.Query

  def resolve_presigned_get(%{id: user_profile_id}, _args, %{
        definition: %{name: "propicFileDownloadUrl"}
      }) do
    {:ok,
     Repo.get_by(UserFile, %{user_profile_id: user_profile_id, file_type: "propic_file"})
     |> CreatePresignedUrl.handle(:get)}
  end

  def resolve_profile(_parent, %{user_id: user_id}, _resolution) do
    result = Repo.get_by(UserProfile, user_id: user_id) |> Repo.preload(:social_accounts)

    {:ok, result}
  end

  def resolve_profiles(_parent, users, _resolution) do
    user_ids = users |> Enum.map(fn user -> user.id end)

    result =
      UserProfile
      |> where([up], up.user_id in ^user_ids)
      |> select([up], up)
      |> preload(:social_accounts)
      |> Repo.all()

    {:ok, result}
  end
end
