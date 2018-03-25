defmodule CodeSponsorWeb.CreativeControllerTest do
  use CodeSponsorWeb.ConnCase


  describe "CreativeController" do
    test "index should render index page", %{conn: conn} do
      insert_list(25, :creative)
      user = insert(:user, %{roles: ["sponsor"]})
      conn = assign conn, :current_user, user
      conn = get conn, creative_path(conn, :index)
      assert html_response(conn, 200) =~ "Home"
    end

    test "new should render index creative form", %{conn: conn} do
      insert_list(25, :creative)
      user = insert(:user, %{roles: ["sponsor"]})
      conn = assign conn, :current_user, user
      conn = get conn, creative_path(conn, :new)
      assert html_response(conn, 200) =~ "Add Creative"
    end

    test "new should render a creative for editing", %{conn: conn} do
      creative = insert(:creative)
      user = insert(:user, %{roles: ["sponsor"]})
      conn = assign conn, :current_user, user
      conn = get conn, creative_path(conn, :show, creative)
      assert html_response(conn, 200) =~ "Edit Creative"
    end

    test "create should save a creative", %{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      conn = assign conn, :current_user, user
      assert Repo.aggregate(CodeSponsor.Schema.Creative, :count, :id) == 0
      params = %{
        "creative" => %{
          "name" => "name",
          "body" => "body",
          "image_url" => "https://url.u"
        }
      }
      conn = post conn, creative_path(conn, :create), params
      assert html_response(conn, 302)
      assert Repo.aggregate(CodeSponsor.Schema.Creative, :count, :id) == 1
    end

    test "update should save a creative", %{conn: conn} do
      creative = insert(:creative)
      user = insert(:user, %{roles: ["admin"]})
      conn = assign conn, :current_user, user
      params = %{
        "creative" => %{
          "name" => "namey",
          "body" => "body",
          "image_url" => "https://urly.u"
        }
      }
      conn = patch conn, creative_path(conn, :update, creative), params
      assert html_response(conn, 302)
      updated_creative = Repo.one(CodeSponsor.Schema.Creative)
      assert updated_creative.name == "namey"
    end

    test "deletes a creative", %{conn: conn} do
      creative = insert(:creative)
      user = insert(:user, %{roles: ["sponsor"]})
      conn = assign conn, :current_user, user
      assert Repo.aggregate(CodeSponsor.Schema.Creative, :count, :id) == 1
      conn = delete conn, creative_path(conn, :delete, creative)
      assert html_response(conn, 302)
      assert Repo.aggregate(CodeSponsor.Schema.Creative, :count, :id) == 0
    end
  end
end
