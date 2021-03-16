defmodule NudgeApiWeb.Resolvers.Queries.CurrentUser do
  import Ecto.Query

  alias NudgeApi.Users.{UserProfile, UserFile}
  alias NudgeApi.Users.Actions.CreatePresignedUrl
  alias NudgeApi.{Repo}

  require Logger

  defp build_url(current_user_id, file_type) do
    UserProfile
    |> where(user_id: ^current_user_id)
    |> join(:inner, [up], uf in UserFile,
      on: up.id == uf.user_profile_id and uf.file_type == ^file_type
    )
    |> select([up, uf], uf)
    |> Repo.one!()
    |> CreatePresignedUrl.handle(:put)
  end

  def resolve_presigned_put(_parent, _args, %{
        context: %{current_user: %{id: current_user_id}},
        definition: %{name: "propicFileUploadUrl"}
      }) do
    {:ok, build_url(current_user_id, "propic_file")}
  end

  def resolve_presigned_put(_parent, _args, %{
        context: %{current_user: %{id: current_user_id}},
        definition: %{name: "idFileUploadUrl"}
      }) do
    {:ok, build_url(current_user_id, "id_file")}
  end

  def resolve_presigned_put(_parent, _args, %{
        context: %{current_user: %{id: current_user_id}},
        definition: %{name: "faceFileUploadUrl"}
      }) do
    {:ok, build_url(current_user_id, "face_file")}
  end
end
