defmodule CodeSponsorWeb.PropertyControllerTest do
  use CodeSponsorWeb.ConnCase

  describe "PropertyController" do
    test "index/0", %{conn: conn} do
      user = insert(:user, %{roles: ["developer"]})
      insert_list(25, :property, user: user)
      conn = assign conn, :current_user, user

      conn = get conn, property_path(conn, :index)
      assert html_response(conn, 200)
    end

    test "index/0 redirects unauth user", %{conn: conn} do
      user = insert(:user)
      conn = assign conn, :current_user, user
      conn = get conn, property_path(conn, :index)
      assert html_response(conn, 302)
    end

    test "new/2", %{conn: conn} do
      user = insert(:user, %{roles: ["developer"]})
      conn = assign conn, :current_user, user

      conn = get conn, property_path(conn, :new)
      assert html_response(conn, 200)
    end

    test "show should show a property", %{conn: conn} do
      user = insert(:user, %{roles: ["developer"]})
      conn = assign conn, :current_user, user
      property = insert(:property)
      conn = get conn, property_path(conn, :show, property)
      assert html_response(conn, 200) =~ "Edit Property"
    end

    test "edit should show a property edit form", %{conn: conn} do
      user = insert(:user, %{roles: ["developer"]})
      conn = assign conn, :current_user, user
      property = insert(:property)
      conn = get conn, property_path(conn, :edit, property)
      assert html_response(conn, 200) =~ "Edit Property"
    end

    test "deletes a property", %{conn: conn} do
      user = insert(:user, %{roles: ["developer"]})
      conn = assign conn, :current_user, user
      property = insert(:property)
      assert Repo.aggregate(CodeSponsor.Schema.Property, :count, :id) == 1
      conn = delete conn, property_path(conn, :delete, property)
      assert html_response(conn, 302)
      assert Repo.aggregate(CodeSponsor.Schema.Property, :count, :id) == 0

    end

    # test "create/2", %{conn: conn} do
    #   user = insert(:user, %{roles: ["admin"]})
    #   conn = assign conn, :current_user, user
    #   assert Repo.aggregate(CodeSponsor.Schema.Property, :count, :id) == 0
    #   params = %{
    #     "property" => %{
    #       "name" => "property_name",
    #       "url" => "https://logivo.b",
    #       "property_type" => 1,
    #       "user_id" => user.id
    #     }
    #   }
    #   conn = post conn, property_path(conn, :create), params
    #   assert html_response(conn, 302)
    #   assert Repo.aggregate(CodeSponsor.Schema.Property, :count, :id) == 1
    # end

    # test "update/2", %{conn: conn} do
    #   user = insert(:user, %{roles: ["admin"]})
    #   conn = assign conn, :current_user, user
    #   property = insert(:property)
    #   assert Repo.aggregate(CodeSponsor.Schema.Property, :count, :id) == 1
    #   params = %{
    #     "property" => %{
    #       "name" => "property_name",
    #       "url" => "https://logivo.b",
    #       "property_type" => 1,
    #       "user_id" => user.id
    #     }
    #   }
    #   conn = patch conn, property_path(conn, :update, property), params
    #   assert html_response(conn, 302)
    #   updated_prop = Repo.one(CodeSponsor.Schema.Property)
    #   assert updated_prop.name == params["property"]["name"]
    # end






  end
end
