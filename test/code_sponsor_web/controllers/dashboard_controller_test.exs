defmodule CodeSponsorWeb.DashboardControllerTest do
  use CodeSponsorWeb.ConnCase

  describe "DashboardController" do
    test "renders index when user logged in", %{conn: conn} do
      user = insert(:user, %{roles: ["developer"]})
      conn = assign conn, :current_user, user
      conn = get conn, "/dashboard"
      assert html_response(conn, 200)
    end
  end
end
