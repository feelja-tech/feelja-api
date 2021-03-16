defmodule NudgeApi.Users.SocialAccount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "social_accounts" do
    field :user_profile_id, :id

    field :account_type, :string

    field :access_token, :string
    field :expires_at, :utc_datetime
    field :access_token_metadata, :map

    field :data, :map

    belongs_to :user_profile, NudgeApi.Users.UserProfile, define_field: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(social_account, attrs) do
    social_account
    |> cast(attrs, [
      :user_profile_id,
      :account_type,
      :access_token,
      :expires_at,
      :access_token_metadata,
      :data
    ])
    |> validate_required([:user_profile_id, :access_token, :account_type])
    |> unique_constraint(:unique_social_network_per_profile,
      name: :unique_social_network_per_profile_index
    )
  end
end
