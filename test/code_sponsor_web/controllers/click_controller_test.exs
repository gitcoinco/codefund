defmodule CodeSponsorWeb.ClickControllerTest do
  use CodeSponsorWeb.ConnCase



  describe "ClickController" do
    test "index/2 should show a list of clicks",%{conn: conn} do
      insert_list(25, :click)
      user = insert(:user, %{roles: ["admin"]})
      conn = assign conn, :current_user, user
      conn = get conn, click_path(conn, :index)
      assert html_response(conn, 200)
    end

    test "new/2 should show a click form",%{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      conn = assign conn, :current_user, user
      conn = get conn, click_path(conn, :new)
      assert html_response(conn, 200)
    end

    test "show/2 should show a click form",%{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      click = insert(:click)
      conn = assign conn, :current_user, user
      conn = get conn, click_path(conn, :show, click)
      assert html_response(conn, 200) =~ "Show Click"
    end

    test "show/2 should show an edit form",%{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      click = insert(:click)
      conn = assign conn, :current_user, user
      conn = get conn, click_path(conn, :edit, click)
      assert html_response(conn, 200) =~ "Edit Click"
    end

    test "delete/2 should delit a click",%{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      click = insert(:click)
      conn = assign conn, :current_user, user
      assert Repo.aggregate(CodeSponsor.Schema.Click, :count, :id) == 1

      conn = delete conn, click_path(conn, :delete, click)
      assert html_response(conn, 302)
      assert Repo.aggregate(CodeSponsor.Schema.Click, :count, :id) == 0
    end

    # test "create/2 should show a click form",%{conn: conn} do
    #   user = insert(:user, %{roles: ["developer"]})
    #   property = insert(:property, user: user)
    #   conn = assign conn, :current_user, user
    #   params = %{
    #     "click" => %{
    #       ip: "121.12.1.31",
    #       revenue_amount: ~n(2.00),
    #       distribution_amount: ~n(1.20)},
    #       property_id: property.id
    #   }
    #   assert Repo.aggregate(CodeSponsor.Schema.Click, :count, :id) == 0
    #
    #   conn = post conn, click_path(conn, :create), params
    #   assert html_response(conn, 200)
    #   assert Repo.aggregate(CodeSponsor.Schema.Click, :count, :id) == 1
    # end
  end

end
