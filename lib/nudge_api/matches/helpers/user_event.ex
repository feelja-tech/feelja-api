defmodule NudgeApi.Matches.Helpers.UserEvent do
  alias NudgeApi.Users.User

  alias NudgeApi.Matches.{
    Helpers,
    UserMeeting,
    UserVideoCall,
    UserMatch,
    Match,
    Meeting,
    VideoCall
  }

  @callback list_undetermined(%User{}) ::
              list(%UserMeeting{} | %UserVideoCall{} | %UserMatch{})

  @callback get_undetermined!(%User{}, %Meeting{} | %VideoCall{} | %Match{}) ::
              %Meeting{} | %VideoCall{} | %Match{}

  @spec list_undetermined(any, %User{}) ::
          list(%UserMeeting{} | %UserVideoCall{} | %UserMatch{})
  def list_undetermined(implementation, user) do
    implementation.list_undetermined(user)
  end

  @callback get_undetermined!(%Meeting{} | %VideoCall{} | %Match{}, %User{}) ::
              %UserMeeting{} | %UserVideoCall{} | %UserMatch{}
  def get_undetermined!(event, user) do
    implementation =
      event
      |> case do
        %Meeting{} -> Helpers.UserMeeting
        %VideoCall{} -> Helpers.UserVideoCall
        %Match{} -> Helpers.UserMatch
      end

    implementation.get_undetermined!(user, event)
  end
end
