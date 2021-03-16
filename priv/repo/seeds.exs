alias NudgeApi.{Repo, Users, Matches}
alias NudgeApi.Users.{User, UserFile, UserProfile}
alias NudgeApi.Matches.{Match, UserMatch}

with :dev <- Mix.env() do
  for i <- 0..5,
      i > 0 do
    {:ok, user = %User{id: user_id}} =
      Users.Actions.InitializeUser.handle(
        phone_number:
          Faker.Phone.EnGb.mobile_number()
          |> case do
            "+" <> _ = phone_number -> phone_number
            phone_number -> "+#{phone_number}"
          end
          |> String.replace(" ", "")
      )

    Repo.get_by!(UserProfile, user_id: user_id)
    |> UserProfile.changeset(%{
      # birthdate: Faker.Date.date_of_birth(),
      # dating_preferences: [Enum.random(["relationship", "hookup"])],
      # education_level: Enum.random(["Undergrad", "Bachelor", "Master", "Doctor", "PostDoc"]),
      # education_subject:
      #   Enum.random([
      #     "Business",
      #     "Economics",
      #     "Life sciences",
      #     "Arts & humanities",
      #     "Engineering",
      #     "Physical sciences",
      #     "Social sciences",
      #     "Computer science",
      #     "Education",
      #     "Law",
      #     "Healthcare",
      #     "Psychology"
      #   ]),
      # employment: Faker.Person.En.title_job(),
      # ethnicity: Enum.random(["white", "asian", "black"]),
      # gender_preferences: [Enum.random(["male", "female"])],
      description: %{},
      gender: Enum.random(["male", "female"]),
      height: Enum.random(150..200),
      location: %{},
      name: Faker.Person.first_name(),
      politic_preferences: [Enum.random(["liberal", "conservative", "apolitical", "center"])],
      religious_preferences: [
        Enum.random(["atheist", "agnostic", "catholic", "muslim", "protestant", "buddhist"])
      ],
      score: :rand.uniform_real(),
      age: Enum.random(20..50)
    })
    |> Repo.update!()

    Machinery.transition_to(user, NudgeApi.Fsms.UserFsm, :waiting_match)
  end
end
