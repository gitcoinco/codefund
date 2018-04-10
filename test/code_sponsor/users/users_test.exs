defmodule CodeFund.UsersTest do
  use CodeFund.DataCase
  alias CodeFund.Users

  describe "users" do
    test "has_role?/2 returns true if the user's role is in the set of roles" do
      assert Users.has_role?(["admin", "sponsor"], ["sponsor"])
    end

    test "has_role?/2 returns false if the user's role is not in the set of roles" do
      refute Users.has_role?(["admin", "sponsor"], ["developer"])
    end
  end
end
