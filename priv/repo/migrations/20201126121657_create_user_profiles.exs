defmodule NudgeApi.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create table(:user_profiles) do
      # OCR results
      add :gender, :string

      # Direct inputs
      add :name, :string
      add :age, :integer
      add :height, :integer
      add :employment, :string
      add :education_subject, :string
      add :education_level, :string
      add :gender_preferences, {:array, :string}
      add :dating_preferences, {:array, :string}
      add :politic_preferences, {:array, :string}
      add :religious_preferences, {:array, :string}
      add :location, :map

      add :score, :decimal

      add :description, :map

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:user_profiles, [:user_id])
  end
end
