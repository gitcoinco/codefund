defmodule CodeSponsorWeb.RegistrationControllerTest do
  use CodeSponsorWeb.ConnCase
  import CodeSponsor.Factory
  alias CodeSponsor.Repo
  alias CodeSponsor.Schema.User

  describe "create" do
    test "sets role of new users as 'developer'", %{conn: conn} do
      conn = assign conn, :current_user, nil
      params = %{
        "registration" => %{
          "first_name" => "John",
          "last_name" => "Doe",
          "email" => "john.doe@example.com",
          "password" => "123123"
        }
      }
      conn = post conn, registration_path(conn, :create), params
      assert html_response(conn, 302)

      user = User |> Repo.get_by(email: "john.doe@example.com")
      assert user.first_name == "John"
      assert user.roles == ["developer"]
    end
  end

end