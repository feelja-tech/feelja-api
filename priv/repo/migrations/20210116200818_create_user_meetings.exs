defmodule NudgeApi.Repo.Migrations.CreateUserMeetings do
  use Ecto.Migration

  def change do
    create table(:user_meetings) do
      add :availabilities, {:array, :utc_datetime}
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :meeting_id, references(:meetings, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:user_meetings, [:user_id])
    create index(:user_meetings, [:meeting_id])

    create unique_index(:user_meetings, [:user_id, :meeting_id], name: :unique_user_meeting_per_meeting)
  end
end
