defmodule NudgeApi.Repo.Migrations.CreateUserVideoCalls do
  use Ecto.Migration

  def change do
    create table(:user_video_calls) do
      add :availabilities, {:array, :utc_datetime}
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :video_call_id, references(:video_calls, on_delete: :delete_all), null: false
      add :access_token, :string, size: 1000
      add :chosen, :boolean
      add :initiator, :boolean, default: false, null: false


      timestamps(type: :utc_datetime)
    end

    create index(:user_video_calls, [:user_id])
    create index(:user_video_calls, [:video_call_id])

    create unique_index(:user_video_calls, [:user_id, :video_call_id], name: :unique_user_video_call_per_video_call)
  end
end
