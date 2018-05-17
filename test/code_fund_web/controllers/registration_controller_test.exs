defmodule CodeFundWeb.RegistrationControllerTest do
  use CodeFundWeb.ConnCase
  alias CodeFund.Repo
  alias CodeFund.Schema.User

  describe "create" do
    test "sets role of new users as 'developer'", %{conn: conn} do
      conn = assign(conn, :current_user, nil)
      pid = Process.whereis(CodeFundWeb.Notificator)
      :erlang.trace(pid, true, [:receive])

      params = %{
        "registration" => %{
          "first_name" => "John",
          "last_name" => "Doe",
          "email" => "john.doe@example.com",
          "password" => "123123"
        }
      }

      conn = post(conn, registration_path(conn, :create), params)
      assert html_response(conn, 302)

      user = User |> Repo.get_by(email: "john.doe@example.com")
      assert user.first_name == "John"
      assert user.roles == ["developer"]

      assert_receive {:trace, ^pid, :receive,
                      {:"$gen_cast",
                       {:message, "User John Doe (john.doe@example.com) just registered!"}}}
    end
  end
end
