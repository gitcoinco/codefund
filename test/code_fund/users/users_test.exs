defmodule CodeFund.UsersTest do
  use CodeFund.DataCase
  import CodeFund.Factory
  alias CodeFund.Users
  alias CodeFund.Schema.User

  describe "users" do
    test "has_role?/2 returns true if the user's role is in the set of roles" do
      assert Users.has_role?(["admin", "sponsor"], ["sponsor"])
    end

    test "has_role?/2 returns false if the user's role is not in the set of roles" do
      refute Users.has_role?(["admin", "sponsor"], ["developer"])
    end

    test "get_by_email/1 finds a user by email" do
      insert(:user, email: "wrong_one@example.com")
      user = insert(:user, email: "right_one@example.com")
      assert user == Users.get_by_email("right_one@example.com")
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user, first_name: "Old Name")
      assert {:ok, user} = Users.update_user(user, %{"first_name" => "New Name"})
      # reload
      user = Users.get_user!(user.id)
      assert User == user.__struct__
      assert user.first_name == "New Name"
    end
  end
end
