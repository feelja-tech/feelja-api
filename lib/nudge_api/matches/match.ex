defmodule NudgeApi.Matches.Match do
  use Ecto.Schema
  import Ecto.Changeset

  schema "matches" do
    field :finalized_at, :utc_datetime

    has_many :user_matches, NudgeApi.Matches.UserMatch

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(match, attrs) do
    match
    |> cast(attrs, [:finalized_at])
    |> validate_required([])
  end
end
