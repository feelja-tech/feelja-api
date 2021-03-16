defmodule NudgeApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :phone_number, :string, null: false
      add :sms_code, :string
      add :state, :string, default: "incomplete", null: false
      add :otp, :string
      add :otp_expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:phone_number])
    create unique_index(:users, [:otp])
  end
end
