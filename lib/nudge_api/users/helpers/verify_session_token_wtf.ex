defmodule NudgeApi.Users.Helpers.SessionTokenWtf do
  # Phoenix.Token.verify/4 alternative. readapted the code from plug_crypto

  alias Plug.Crypto.{KeyGenerator, MessageVerifier}

  defp get_secret(secret_key_base, salt, opts \\ []) do
    iterations = Keyword.get(opts, :key_iterations, 1000)
    length = Keyword.get(opts, :key_length, 32)
    digest = Keyword.get(opts, :key_digest, :sha256)
    cache = Keyword.get(opts, :cache, Plug.Crypto.Keys)
    KeyGenerator.generate(secret_key_base, salt, iterations, length, digest, cache)
  end

  def verify(key_base, salt, token, opts \\ []) do
    secret = get_secret(key_base, salt, opts)

    case MessageVerifier.verify(token, secret) do
      {:ok, message} -> Plug.Crypto.non_executable_binary_to_term(message)
      :error -> {:error, :invalid}
    end
  end
end
