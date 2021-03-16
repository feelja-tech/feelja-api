defmodule NudgeApi.Repo.Migrations.CreateMatches do
  use Ecto.Migration

  def change do
    create table(:matches) do
      add :finalized_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
