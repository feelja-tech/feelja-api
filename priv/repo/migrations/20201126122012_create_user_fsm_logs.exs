defmodule NudgeApi.Repo.Migrations.CreateUserFsmLogs do
  use Ecto.Migration

  def change do
    create table(:user_fsm_logs) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :to_state, :string, null: false
      add :from_state, :string

      timestamps(type: :utc_datetime)
    end
  end
end
