defmodule NudgeApi.Users.Actions.SendNotification do
  alias NudgeApi.Users.{User, Actions}

  # TODO
  defp send_websocket_message do
  end

  def handle(
        %User{
          phone_number: phone_number
        },
        %{
          title: title,
          message: message,
          data: data
        } = body
      ) do
    send_websocket_message
  end
end
