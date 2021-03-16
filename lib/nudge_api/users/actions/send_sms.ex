defmodule NudgeApi.Users.Actions.SendSms do
  defp resolve_from_phone_number(to_phone_number) do
    case(to_phone_number) do
      "+1" <> _ -> System.fetch_env!("TWILIO_US_PHONE")
      "+3" <> _ -> System.fetch_env!("TWILIO_EU_PHONE")
      "+4" <> _ -> System.fetch_env!("TWILIO_EU_PHONE")
    end
  end

  # Tries sending message with alphanumeric ID, if not possible fallback to number
  def handle!(to_phone_number, message) do
    if(Mix.env() == :prod) do
      {:ok, _} =
        ExTwilio.Message.create(
          from: "Feelja",
          to: to_phone_number,
          body: message
        )
        |> case do
          {:error, _, 400} ->
            ExTwilio.Message.create(
              from: resolve_from_phone_number(to_phone_number),
              to: to_phone_number,
              body: message
            )

          res ->
            res
        end
    else
      IO.puts("Message to #{to_phone_number}: #{message}")
    end
  end
end
