defmodule NudgeApiWeb.Schema.ProfileType do
  use Absinthe.Schema.Notation

  alias NudgeApiWeb.Resolvers.Queries

  object :profile do
    field :id, :id, resolve: fn parent, _, _ -> {:ok, parent.user_id} end
    field :age, :integer
    field :description, :json
    field :education_level, :string
    field :education_subject, :string
    field :employment, :string
    field :height, :integer
    field :politic_preferences, list_of(:string)
    field :name, :string
    field :religious_preferences, list_of(:string)
    field :dating_preferences, list_of(:string)
    field :gender, :string
    field :location, :json
    field :gender_preferences, list_of(:string)

    field :score, :decimal

    field :social_accounts, list_of(:string),
      resolve: fn parent, _, _ ->
        account_types =
          parent.social_accounts
          |> Enum.map(fn account ->
            account.account_type
          end)

        {:ok, account_types}
      end

    field :propic_file_download_url, :string, resolve: &Queries.Profile.resolve_presigned_get/3
  end
end
