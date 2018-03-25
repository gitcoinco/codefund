defmodule CodeSponsorWeb.ImpressionControllerTest do
  use CodeSponsorWeb.ConnCase

  describe "Impression Controller" do
    test "index renders index page", %{conn: conn} do
        insert_list(25, :impression)
        user = insert(:user, %{roles: ["admin"]})
        conn = assign conn, :current_user, user
        conn = get conn, impression_path(conn, :index)
        assert html_response(conn, 200) =~ "Impressions"
    end

    test "new renders new impression page", %{conn: conn} do
        user = insert(:user, %{roles: ["admin"]})
        conn = assign conn, :current_user, user
        conn = get conn, impression_path(conn, :new)
        assert html_response(conn, 200) =~ "New Impression"
    end

    test "create saves new impression", %{conn: conn} do
        user = insert(:user, %{roles: ["admin"]})
        property = insert(:property)
        conn = assign conn, :current_user, user
        params =  %{
          "impression" => %{
            "property_id" => property.id,
            "ip" => "19.98.988.980"
          }
        }
        assert Repo.aggregate(CodeSponsor.Schema.Impression, :count, :id) == 0
        conn = post conn, impression_path(conn, :create), params
        assert html_response(conn, 302)
        assert Repo.aggregate(CodeSponsor.Schema.Impression, :count, :id) == 1
    end

    test "show renders an impression page", %{conn: conn} do
        user = insert(:user, %{roles: ["admin"]})
        impression = insert(:impression)
        conn = assign conn, :current_user, user
        conn = get conn, impression_path(conn, :show, impression)
        assert html_response(conn, 200) =~ "Details"
    end

    test "edit renders an impression page for editing", %{conn: conn} do
        user = insert(:user, %{roles: ["admin"]})
        impression = insert(:impression)
        conn = assign conn, :current_user, user
        conn = get conn, impression_path(conn, :edit, impression)
        assert html_response(conn, 200) =~ "Edit Impression"
    end

    test "update edits an impression", %{conn: conn} do
        user = insert(:user, %{roles: ["admin"]})
        property = insert(:property)
        impression = insert(:impression, property: property)
        conn = assign conn, :current_user, user
        params =  %{
          "impression" => %{
            "property_id" => property.id,
            "ip" => "19.98.988.980"
          }
        }
        saved_impression = Repo.one(CodeSponsor.Schema.Impression)
        assert saved_impression.property_id == property.id
        conn = patch conn, impression_path(conn, :update, impression), params
        assert html_response(conn, 302)
        updated_impression = Repo.one(CodeSponsor.Schema.Impression)
        assert updated_impression.property_id == params["impression"]["property_id"]
    end

    test "deletes an impression", %{conn: conn} do
        user = insert(:user, %{roles: ["admin"]})
        impression = insert(:impression)
        assert Repo.aggregate(CodeSponsor.Schema.Impression, :count, :id) == 1
        conn = assign conn, :current_user, user
        delete conn, impression_path(conn, :delete, impression)
        assert Repo.aggregate(CodeSponsor.Schema.Impression, :count, :id) == 0
    end

  end
end
