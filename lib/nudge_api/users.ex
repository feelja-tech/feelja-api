defmodule NudgeApi.Users do
  import Ecto.Query, warn: false
  alias NudgeApi.Repo

  alias NudgeApi.Users.SocialAccount

  def list_social_accounts do
    Repo.all(SocialAccount)
  end

  def get_social_account!(id), do: Repo.get!(SocialAccount, id)

  def create_social_account(attrs \\ %{}) do
    %SocialAccount{}
    |> SocialAccount.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  def update_social_account(%SocialAccount{} = social_account, attrs) do
    social_account
    |> SocialAccount.changeset(attrs)
    |> Repo.update()
  end

  def delete_social_account(%SocialAccount{} = social_account) do
    Repo.delete(social_account)
  end

  def change_social_account(%SocialAccount{} = social_account, attrs \\ %{}) do
    SocialAccount.changeset(social_account, attrs)
  end

  alias NudgeApi.Users.User

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias NudgeApi.Users.UserProfile

  def list_user_profiles do
    Repo.all(UserProfile)
  end

  def get_user_profile!(id), do: Repo.get!(UserProfile, id)

  def create_user_profile(attrs \\ %{}) do
    %UserProfile{}
    |> UserProfile.changeset(attrs)
    |> Repo.insert()
  end

  def update_user_profile(%UserProfile{} = user_profile, attrs) do
    user_profile
    |> UserProfile.changeset(attrs)
    |> Repo.update()
  end

  def delete_user_profile(%UserProfile{} = user_profile) do
    Repo.delete(user_profile)
  end

  def change_user_profile(%UserProfile{} = user_profile, attrs \\ %{}) do
    UserProfile.changeset(user_profile, attrs)
  end

  alias NudgeApi.Users.UserFile

  def list_user_files do
    Repo.all(UserFile)
  end

  def get_user_file!(id), do: Repo.get!(UserFile, id)

  def update_user_file(%UserFile{} = user_file, attrs) do
    user_file
    |> UserFile.changeset(attrs)
    |> Repo.update()
  end

  def delete_user_file(%UserFile{} = user_file) do
    Repo.delete(user_file)
  end

  def change_user_file(%UserFile{} = user_file, attrs \\ %{}) do
    UserFile.changeset(user_file, attrs)
  end
end
