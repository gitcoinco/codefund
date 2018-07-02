defmodule CodeFundWeb.Authentication.PasswordlessControllerTest do
  use CodeFundWeb.ConnCase
  import CodeFund.Factory
  use Bamboo.Test

  describe "GET /new" do
    test "shows the passwordless auth new page", %{conn: conn} do
      conn =
        get(
          conn,
          passwordless_path(conn, :new)
        )

      assert html_response(conn, 200) =~ "Enter your email, first name and last name to begin."
    end
  end

  describe "POST /send" do
    test "sends an email with a token", %{conn: conn} do
      conn =
        post(
          conn,
          passwordless_path(conn, :send, %{
            "first_name" => "Some",
            "last_name" => "Dude",
            "email" => "some_dude@example.com"
          })
        )

      token = conn.assigns.token

      assert {:ok, ["some_dude@example.com", "Some", "Dude"]} ==
               Authentication.Token.verify("some_dude@example.com", token)

      assert conn.private.phoenix_template == "success.html"
      assert conn.assigns.email == "some_dude@example.com"

      assert conn |> Phoenix.Controller.get_flash(:info) ==
               "Your request was submitted successfully."

      assert html_response(conn, 200) =~ "Check your email to finish."

      assert_delivered_email(
        CodeFundWeb.Email.AuthRequest.email(token, "some_dude@example.com", conn)
      )
    end
  end

  describe "GET /complete" do
    test "it creates an account and signs the user in if email and token verify", %{conn: conn} do
      refute CodeFund.Users.get_by_email("some_dude@example.com")

      {:ok, token} = Authentication.Token.sign("some_dude@example.com", "Some", "Dude")

      conn =
        get(
          conn,
          passwordless_path(conn, :complete, %{
            "email" => "some_dude@example.com",
            "token" => token
          })
        )

      %CodeFund.Schema.User{email: "some_dude@example.com"} =
        user = CodeFund.Users.get_by_email("some_dude@example.com")

      assert conn |> Phoenix.Controller.get_flash(:info) == "Successfully logged in."
      assert redirected_to(conn, 302) == dashboard_url(conn, :index)

      assert conn.assigns.current_user.id == user.id
      assert user.password == user.password_confirmation
      assert conn.assigns.current_user.password_hash
    end

    test "it signs the user if the user exists and the token matches", %{conn: conn} do
      user = insert(:user, %{email: "some_dude@example.com"})

      {:ok, token} = Authentication.Token.sign("some_dude@example.com", "Some", "Dude")

      conn =
        get(
          conn,
          passwordless_path(conn, :complete, %{
            "email" => "some_dude@example.com",
            "token" => token
          })
        )

      assert conn |> Phoenix.Controller.get_flash(:info) == "Successfully logged in."
      assert redirected_to(conn, 302) == dashboard_url(conn, :index)

      assert conn.assigns.current_user.id == user.id
      assert user.password == user.password_confirmation
      assert conn.assigns.current_user.password_hash
    end

    test "it returns an error if the token doesn't match the email", %{conn: conn} do
      {:ok, token} = Authentication.Token.sign("some_dude@example.com", "Some", "Dude")

      conn =
        get(
          conn,
          passwordless_path(conn, :complete, %{
            "email" => "wrong_email@example.com",
            "token" => token
          })
        )

      refute conn |> Phoenix.Controller.get_flash(:info)
      assert redirected_to(conn, 302) == dashboard_url(conn, :index)

      refute conn.assigns.current_user
    end
  end
end
