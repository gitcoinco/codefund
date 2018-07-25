defmodule Authentication.Token do
  @max_age :timer.minutes(5) / 1000

  @spec sign(String.t(), String.t(), String.t()) :: {:ok, String.t()}
  def sign(email_address, first_name, last_name) do
    [secret_key: secret_key, salt: salt] = get_secret_and_salt()

    string =
      [email_address, first_name, last_name]
      |> Enum.join("/")

    token =
      secret_key
      |> Phoenix.Token.sign(salt, string)

    {:ok, token}
  end

  @spec verify(String.t(), String.t(), float) :: {:ok, list} | {:error, atom}
  def verify(email_address, token, max_age \\ @max_age) do
    [secret_key: secret_key, salt: salt] = get_secret_and_salt()

    with {:ok, contents} <- Phoenix.Token.verify(secret_key, salt, token, max_age: max_age),
         {:ok, email_regex} <- Regex.compile(email_address),
         true <- Regex.match?(email_regex, contents) do
      [email, first_name, last_name] =
        contents
        |> String.split("/")

      email = email |> String.replace(~r/%2B/, "+")

      {:ok, [email, first_name, last_name]}
    else
      {:error, reason} -> {:error, reason}
      false -> {:error, :invalid}
    end
  end

  defp get_secret_and_salt(), do: Application.get_env(:code_fund, Authentication.Token)
end
