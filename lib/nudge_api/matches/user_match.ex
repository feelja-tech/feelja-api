defmodule NudgeApi.Matches.UserMatch do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_matches" do
    field :unlocked_at, :utc_datetime
    field :chosen, :boolean
    field :initiator, :boolean

    belongs_to :user, NudgeApi.Users.User
    belongs_to :match, NudgeApi.Matches.Match

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_match, attrs) do
    user_match
    |> cast(attrs, [
      :user_id,
      :match_id,
      :unlocked_at,
      :chosen,
      :initiator
    ])
    |> validate_required([:user_id, :match_id])
    |> unique_constraint(:unique_user_match_per_match,
      name: :unique_user_match_per_match_index
    )
  end
end
