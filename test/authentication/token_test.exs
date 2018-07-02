defmodule Authentication.TokenTest do
  use ExUnit.Case

  setup do
    {:ok, token} = Authentication.Token.sign("some_dude@example.com", "Some", "Dude")
    {:ok, %{token: token}}
  end

  test "sign/3 returns a Phoenix Token", %{token: token} do
    assert token |> byte_size == 142
  end

  describe "verify/3" do
    test "it decodes a phoenix token and returns {:ok, [email, first_name, last name]} if the correct email is passed in",
         %{token: token} do
      assert {:ok, ["some_dude@example.com", "Some", "Dude"]} ==
               Authentication.Token.verify("some_dude@example.com", token)
    end

    test "it returns {:error, :invalid} if the invalid email is passed in", %{token: token} do
      assert {:error, :invalid} == Authentication.Token.verify("wrong_email@example.com", token)
    end

    test "it returns {:error, :expired} if the max age has passed", %{token: token} do
      :timer.sleep(1001)

      assert {:error, :expired} ==
               Authentication.Token.verify(
                 "some_dude@example.com",
                 token,
                 :timer.seconds(1) / 1000
               )
    end
  end
end
