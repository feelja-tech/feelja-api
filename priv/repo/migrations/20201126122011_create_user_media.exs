defmodule NudgeApi.Repo.Migrations.CreateUserFiles do
  use Ecto.Migration

  def change do
    create table(:user_files) do
      add :file_type, :string, null: false
      add :user_profile_id, references(:user_profiles, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_files, [:user_profile_id, :file_type], name: :unique_file_type_per_profile_index)
  end
end
