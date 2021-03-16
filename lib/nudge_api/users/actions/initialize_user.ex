defmodule NudgeApi.Users.Actions.InitializeUser do
  alias NudgeApi.Repo
  alias NudgeApi.Users.{UserFile, UserProfile, User}

  def handle(phone_number: phone_number) do
    Repo.transaction(fn ->
      %User{id: user_id} = user = Repo.insert!(%User{phone_number: phone_number})
      %UserProfile{id: user_profile_id} = Repo.insert!(%UserProfile{user_id: user_id})
      Repo.insert!(%UserFile{user_profile_id: user_profile_id, file_type: "face_file"})
      Repo.insert!(%UserFile{user_profile_id: user_profile_id, file_type: "propic_file"})
      Repo.insert!(%UserFile{user_profile_id: user_profile_id, file_type: "id_file"})
      user
    end)
  end
end
