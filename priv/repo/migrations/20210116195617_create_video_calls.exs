defmodule NudgeApi.Repo.Migrations.CreateVideoCalls do
  use Ecto.Migration

  def change do
    create table(:video_calls) do
      add :happens_at, :utc_datetime
      add :finalized_at, :utc_datetime

      add :match_id, references(:matches, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

  end
end
