defmodule NudgeApi.Matches do
  import Ecto.Query, warn: false
  alias NudgeApi.Repo

  alias NudgeApi.Matches.UserMatch

  def list_user_matches do
    Repo.all(UserMatch)
  end

  def get_user_match!(id), do: Repo.get!(UserMatch, id)

  def create_user_match(attrs \\ %{}) do
    %UserMatch{}
    |> UserMatch.changeset(attrs)
    |> Repo.insert()
  end

  def update_user_match(%UserMatch{} = user_match, attrs) do
    user_match
    |> UserMatch.changeset(attrs)
    |> Repo.update()
  end

  def delete_user_match(%UserMatch{} = user_match) do
    Repo.delete(user_match)
  end

  def change_user_match(%UserMatch{} = user_match, attrs \\ %{}) do
    UserMatch.changeset(user_match, attrs)
  end

  alias NudgeApi.Matches.Match

  def list_matches do
    Repo.all(Match)
  end

  def get_match!(id), do: Repo.get!(Match, id)

  def create_match(attrs \\ %{}) do
    %Match{}
    |> Match.changeset(attrs)
    |> Repo.insert()
  end

  def update_match(%Match{} = match, attrs) do
    match
    |> Match.changeset(attrs)
    |> Repo.update()
  end

  def delete_match(%Match{} = match) do
    Repo.delete(match)
  end

  def change_match(%Match{} = match, attrs \\ %{}) do
    Match.changeset(match, attrs)
  end

  alias NudgeApi.Matches.VideoCall

  @doc """
  Returns the list of video_calls.

  ## Examples

      iex> list_video_calls()
      [%VideoCall{}, ...]

  """
  def list_video_calls do
    Repo.all(VideoCall)
  end

  @doc """
  Gets a single video_call.

  Raises `Ecto.NoResultsError` if the Video call does not exist.

  ## Examples

      iex> get_video_call!(123)
      %VideoCall{}

      iex> get_video_call!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video_call!(id), do: Repo.get!(VideoCall, id)

  @doc """
  Creates a video_call.

  ## Examples

      iex> create_video_call(%{field: value})
      {:ok, %VideoCall{}}

      iex> create_video_call(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video_call(attrs \\ %{}) do
    %VideoCall{}
    |> VideoCall.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a video_call.

  ## Examples

      iex> update_video_call(video_call, %{field: new_value})
      {:ok, %VideoCall{}}

      iex> update_video_call(video_call, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video_call(%VideoCall{} = video_call, attrs) do
    video_call
    |> VideoCall.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a video_call.

  ## Examples

      iex> delete_video_call(video_call)
      {:ok, %VideoCall{}}

      iex> delete_video_call(video_call)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video_call(%VideoCall{} = video_call) do
    Repo.delete(video_call)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video_call changes.

  ## Examples

      iex> change_video_call(video_call)
      %Ecto.Changeset{data: %VideoCall{}}

  """
  def change_video_call(%VideoCall{} = video_call, attrs \\ %{}) do
    VideoCall.changeset(video_call, attrs)
  end

  alias NudgeApi.Matches.Meeting

  @doc """
  Returns the list of meetings.

  ## Examples

      iex> list_meetings()
      [%Meeting{}, ...]

  """
  def list_meetings do
    Repo.all(Meeting)
  end

  @doc """
  Gets a single meetings.

  Raises `Ecto.NoResultsError` if the Meeting does not exist.

  ## Examples

      iex> get_meetings!(123)
      %Meeting{}

      iex> get_meetings!(456)
      ** (Ecto.NoResultsError)

  """
  def get_meeting!(id), do: Repo.get!(Meeting, id)

  @doc """
  Creates a meetings.

  ## Examples

      iex> create_meetings(%{field: value})
      {:ok, %Meeting{}}

      iex> create_meetings(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_meeting(attrs \\ %{}) do
    %Meeting{}
    |> Meeting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a meetings.

  ## Examples

      iex> update_meetings(meetings, %{field: new_value})
      {:ok, %Meeting{}}

      iex> update_meetings(meetings, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_meeting(%Meeting{} = meeting, attrs) do
    meeting
    |> Meeting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a meetings.

  ## Examples

      iex> delete_meetings(meetings)
      {:ok, %Meeting{}}

      iex> delete_meetings(meetings)
      {:error, %Ecto.Changeset{}}

  """
  def delete_meeting(%Meeting{} = meeting) do
    Repo.delete(meeting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking meetings changes.

  ## Examples

      iex> change_meetings(meetings)
      %Ecto.Changeset{data: %Meeting{}}

  """
  def change_meeting(%Meeting{} = meeting, attrs \\ %{}) do
    Meeting.changeset(meeting, attrs)
  end

  alias NudgeApi.Matches.UserMeeting

  @doc """
  Returns the list of user_meetings.

  ## Examples

      iex> list_user_meetings()
      [%UserMeeting{}, ...]

  """
  def list_user_meetings do
    Repo.all(UserMeeting)
  end

  @doc """
  Gets a single user_meeting.

  Raises `Ecto.NoResultsError` if the User meeting does not exist.

  ## Examples

      iex> get_user_meeting!(123)
      %UserMeeting{}

      iex> get_user_meeting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_meeting!(id), do: Repo.get!(UserMeeting, id)

  @doc """
  Creates a user_meeting.

  ## Examples

      iex> create_user_meeting(%{field: value})
      {:ok, %UserMeeting{}}

      iex> create_user_meeting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_meeting(attrs \\ %{}) do
    %UserMeeting{}
    |> UserMeeting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_meeting.

  ## Examples

      iex> update_user_meeting(user_meeting, %{field: new_value})
      {:ok, %UserMeeting{}}

      iex> update_user_meeting(user_meeting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_meeting(%UserMeeting{} = user_meeting, attrs) do
    user_meeting
    |> UserMeeting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_meeting.

  ## Examples

      iex> delete_user_meeting(user_meeting)
      {:ok, %UserMeeting{}}

      iex> delete_user_meeting(user_meeting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_meeting(%UserMeeting{} = user_meeting) do
    Repo.delete(user_meeting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_meeting changes.

  ## Examples

      iex> change_user_meeting(user_meeting)
      %Ecto.Changeset{data: %UserMeeting{}}

  """
  def change_user_meeting(%UserMeeting{} = user_meeting, attrs \\ %{}) do
    UserMeeting.changeset(user_meeting, attrs)
  end

  alias NudgeApi.Matches.UserVideoCall

  @doc """
  Returns the list of user_video_calls.

  ## Examples

      iex> list_user_video_calls()
      [%UserVideoCall{}, ...]

  """
  def list_user_video_calls do
    Repo.all(UserVideoCall)
  end

  @doc """
  Gets a single user_video_call.

  Raises `Ecto.NoResultsError` if the User video call does not exist.

  ## Examples

      iex> get_user_video_call!(123)
      %UserVideoCall{}

      iex> get_user_video_call!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_video_call!(id), do: Repo.get!(UserVideoCall, id)

  @doc """
  Creates a user_video_call.

  ## Examples

      iex> create_user_video_call(%{field: value})
      {:ok, %UserVideoCall{}}

      iex> create_user_video_call(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_video_call(attrs \\ %{}) do
    %UserVideoCall{}
    |> UserVideoCall.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_video_call.

  ## Examples

      iex> update_user_video_call(user_video_call, %{field: new_value})
      {:ok, %UserVideoCall{}}

      iex> update_user_video_call(user_video_call, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_video_call(%UserVideoCall{} = user_video_call, attrs) do
    user_video_call
    |> UserVideoCall.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_video_call.

  ## Examples

      iex> delete_user_video_call(user_video_call)
      {:ok, %UserVideoCall{}}

      iex> delete_user_video_call(user_video_call)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_video_call(%UserVideoCall{} = user_video_call) do
    Repo.delete(user_video_call)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_video_call changes.

  ## Examples

      iex> change_user_video_call(user_video_call)
      %Ecto.Changeset{data: %UserVideoCall{}}

  """
  def change_user_video_call(%UserVideoCall{} = user_video_call, attrs \\ %{}) do
    UserVideoCall.changeset(user_video_call, attrs)
  end
end
