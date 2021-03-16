defmodule NudgeApi.Repo.Migrations.CreateMeeting do
  use Ecto.Migration

  def change do
    create table(:meetings) do
      add :happens_at, :utc_datetime
      add :finalized_at, :utc_datetime
      add :location, :map

      add :video_call_id, references(:video_calls, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

  end
end
