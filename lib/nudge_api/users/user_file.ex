defmodule NudgeApi.Users.UserFile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_files" do
    field :user_profile_id, :id
    field :file_type, :string

    belongs_to :user_profile, NudgeApi.Users.UserProfile, define_field: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_file, attrs) do
    user_file
    |> cast(attrs, [:file_type])
    |> validate_required([:file_type])
    |> unique_constraint(:unique_file_type_per_profile,
      name: :unique_file_type_per_profile_index
    )
  end
end
