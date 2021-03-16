defmodule NudgeApi.Triggers.DatabaseListener do
  use GenServer

  require Logger

  import Poison, only: [decode!: 1]

  alias NudgeApi.Triggers.Matches.{InitiatorUserMatchCreated, MeetingLocationUpdated}

  @doc """
  Initialize the GenServer
  """
  @spec start_link([String.t()], [any]) :: {:ok, pid}
  def start_link(channel, otp_opts \\ []), do: GenServer.start_link(__MODULE__, channel, otp_opts)

  @doc """
  When the GenServer starts subscribe to the given channel
  """
  def init(channel) do
    Logger.debug("Starting #{__MODULE__} with channel subscription: #{channel}")
    pg_config = NudgeApi.Repo.config()
    {:ok, pid} = Postgrex.Notifications.start_link(pg_config)
    {:ok, ref} = Postgrex.Notifications.listen(pid, channel)
    {:ok, {pid, channel, ref}}
  end

  @doc """
  Listen for changes
  """
  def handle_info({:notification, _pid, _ref, "table_changes", payload}, _state) do
    payload
    |> decode!()
    |> case do
      %{"table" => "user_matches", "type" => "INSERT", "new_row_data" => %{"user_id" => user_id}} ->
        InitiatorUserMatchCreated.handle!(user_id)

      %{"table" => "meetings", "type" => "UPDATE", "id" => meeting_id} ->
        MeetingLocationUpdated.handle!(meeting_id)
    end

    # change will decode json into a list with:
    # type - what crud operation it is
    # table - what table it was done on
    # id - the ID of the row, but will also be in the old and new row data
    # new_row_data - the new data either inserted or updated on the row, or nil in case of delete
    # old_row_data - the old data that use to be on the row, or nil in case of insert
    # You can get these with change["type"] for instance and do whatever you want with them below this line

    {:noreply, :event_handled}
  end

  def handle_info(_, _state), do: {:noreply, :event_received}
end
