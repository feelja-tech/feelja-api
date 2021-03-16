defmodule NudgeApi.Repo.Migrations.CreateSocialAccounts do
  use Ecto.Migration

  def change do
    create table(:social_accounts) do
      add :user_profile_id, references(:user_profiles, on_delete: :delete_all), null: false

      add :account_type, :string, null: false

      add :access_token, :string, size: 1000
      add :expires_at, :utc_datetime
      add :access_token_metadata, :map

      add :data, :map

      timestamps(type: :utc_datetime)
    end

    create unique_index(:social_accounts, [:user_profile_id, :account_type], name: :unique_social_network_per_profile)
  end
end
