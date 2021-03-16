defmodule NudgeApi.Users.UserProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_profiles" do
    # OCR results
    field :gender, :string

    # Direct input
    field :name, :string
    field :age, :integer
    field :height, :integer
    field :employment, :string
    field :education_subject, :string
    field :education_level, :string
    field :gender_preferences, {:array, :string}
    field :dating_preferences, {:array, :string}
    field :politic_preferences, {:array, :string}
    field :religious_preferences, {:array, :string}
    field :location, :map

    field :score, :decimal

    field :description, :map

    field :user_id, :id

    has_many :user_files, NudgeApi.Users.UserFile
    has_many :social_accounts, NudgeApi.Users.SocialAccount

    belongs_to :user, NudgeApi.Users.User, define_field: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_profile, attrs) do
    user_profile
    |> cast(attrs, [
      :name,
      :gender,
      :age,
      :height,
      :employment,
      :education_subject,
      :education_level,
      :gender_preferences,
      :dating_preferences,
      :politic_preferences,
      :religious_preferences,
      :location,
      :description,
      :score
    ])
    |> validate_required([])
    |> unique_constraint(:user_id)
  end
end
