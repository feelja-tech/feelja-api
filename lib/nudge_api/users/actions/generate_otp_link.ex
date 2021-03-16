defmodule NudgeApi.Users.Actions.GenerateOtpLink do
  alias NudgeApi.Users

  @otp_size 20

  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64() |> binary_part(0, length)
  end

  def handle!(user = %Users.User{}) do
    otp = random_string(@otp_size)

    {:ok, _} =
      user
      |> Users.update_user(%{
        otp: otp,
        otp_expires_at: Timex.shift(Timex.now(), days: 1)
      })

    System.fetch_env!("API_URL") <> "/api/login_otp?otp=" <> otp
  end
end
