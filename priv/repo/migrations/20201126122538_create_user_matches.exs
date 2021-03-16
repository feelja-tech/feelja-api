defmodule NudgeApi.Repo.Migrations.CreateUserMatches do
  use Ecto.Migration

  def change do
    create table(:user_matches) do
      add :initiator, :boolean, default: false, null: false
      add :chosen, :boolean
      add :unlocked_at, :utc_datetime

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :match_id, references(:matches, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_matches, [:user_id])
    create index(:user_matches, [:match_id])

    create unique_index(:user_matches, [:user_id, :match_id], name: :unique_user_match_per_match)
  end
end
