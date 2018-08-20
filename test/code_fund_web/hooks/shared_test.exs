defmodule CodeFundWeb.Hooks.SharedTest do
  use CodeFundWeb.ConnCase

  describe "join_to_current_user_id" do
    test "it returns a tuple with user_id and the current_user's id from the conn" do
      user = stub_users().developer
      conn = assign(build_conn(), :current_user, user)
      assert CodeFundWeb.Hooks.Shared.join_to_current_user_id(conn, %{}) == {"user_id", user.id}
    end
  end
end
