defmodule NudgeApiWeb.SessionController do
  use NudgeApiWeb, :controller

  alias NudgeApi.{UserManager, Users, Repo}
  alias NudgeApi.Users.{User}
  alias NudgeApi.Users.Actions.{InitializeUser, SendSms}

  # curl -d '{"phone_number":"393494197577"}' -H "Content-Type: application/json" -X POST http://localhost:4000/api/login

  defp parse_phone_number(phone_number) do
    case(phone_number) do
      "+" <> _ -> phone_number
      _ -> "+#{phone_number}"
    end
    |> String.replace(" ", "")
  end

  # Create or retrieve user
  def login(conn, %{"phone_number" => phone_number}) do
    parsed_phone_number = parse_phone_number(phone_number)

    {:ok, %User{} = user} =
      case Repo.get_by(User, phone_number: parsed_phone_number) do
        nil ->
          InitializeUser.handle(phone_number: parsed_phone_number)

        result ->
          {:ok, result}
      end

    sms_code = Enum.random(10_000..99_999) |> Integer.to_string()

    {:ok, _} = Users.update_user(user, %{sms_code: sms_code})

    SendSms.handle!(
      parsed_phone_number,
      "Your Feelja SMS code: #{sms_code}"
    )

    json(conn, %{success: true})
  end

  # curl -d '{"phone_number":"393494197577","sms_code": "685229"}' -H "Content-Type: application/json" -X POST http://localhost:4000/api/login_2fa

  defp set_cookie(conn, user) do
    conn
    |> fetch_session
    |> put_session("feelja_user", user.id)
  end

  def login_2fa(
        conn,
        %{"phone_number" => phone_number, "sms_code" => incoming_sms_code}
      ) do
    parsed_phone_number = parse_phone_number(phone_number)

    user = User |> Repo.get_by!(phone_number: parsed_phone_number)

    if incoming_sms_code == user.sms_code do
      set_cookie(conn, user)
      |> json(%{success: true})
    else
      json(conn, %{success: false})
    end
  end

  def login_otp(conn, %{"otp" => nil}) do
    redirect(conn, external: System.fetch_env!("FRONTEND_URL") <> "/signup/welcome")
  end

  def login_otp(conn, %{"otp" => otp}) do
    user = User |> Repo.get_by!(otp: otp)

    if user.otp_expires_at > Timex.now() do
      {:ok, _} = Users.update_user(user, %{otp_expires_at: Timex.now()})

      set_cookie(conn, user)
      |> redirect(external: System.fetch_env!("FRONTEND_URL") <> "/main/initial")
      |> halt
    else
      redirect(conn, external: System.fetch_env!("FRONTEND_URL") <> "/signup/welcome")
    end
  end
end
