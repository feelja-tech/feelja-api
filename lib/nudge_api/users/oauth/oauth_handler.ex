defmodule NudgeApi.Users.OAuth.OAuthHandler do
  alias NudgeApi.Users.{UserProfile}

  @callback get_access_token!(%{code: String.t(), jwt: String.t()}) :: %{
              user_profile: %UserProfile{},
              token_data: nil | map()
            }

  @callback process_access_token!(%{
              user_profile: %UserProfile{},
              token_data: nil | map()
            }) :: nil

  def get_access_token!(implementation, params) do
    implementation.get_access_token!(params)
  end

  def process_access_token!(implementation, params) do
    implementation.process_access_token!(params)
  end
end
