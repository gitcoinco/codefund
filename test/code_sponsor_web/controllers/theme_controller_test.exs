defmodule CodeSponsorWeb.ThemeControllerTest do
  use CodeSponsorWeb.ConnCase

  describe "Theme Controller" do
    @tag :admin
    test "index shows a list of themes", %{conn: conn} do
      conn = get conn, theme_path(conn, :index)
      assert html_response(conn, 200) =~ "Code Sponsor | Themes"
    end

    @tag :admin
    test "new shows a form for theme", %{conn: conn} do
      conn = get conn, theme_path(conn, :new)
      assert html_response(conn, 200) =~ "Code Sponsor | Add Theme"
    end


    # @tag :admin
    # test "create saved theme", %{conn: conn} do
    #   params = %{
    #     "theme" => %{
    #       "name" => "name",
    #       "body" => "body",
    #       "slug" => "slug"
    #     }
    #   }
    #   assert Repo.aggregate(CodeSponsor.Schema.Theme, :count, :id) == 0
    #   conn = post conn, theme_path(conn, :create), params
    #   assert html_response(conn, 200)
    #   assert Repo.aggregate(CodeSponsor.Schema.Theme, :count, :id) == 1
    # end

    @tag :admin
    test "show saved theme", %{conn: conn} do
      theme = insert(:theme)
      conn = get conn, theme_path(conn, :show, theme)
      assert html_response(conn, 200) =~ "Code Sponsor | View Theme"
    end

    @tag :admin
    test "deletes saved theme", %{conn: conn} do
      theme = insert(:theme)
      assert Repo.aggregate(CodeSponsor.Schema.Theme, :count, :id) == 1
      conn = delete conn, theme_path(conn, :delete, theme)
      assert Repo.aggregate(CodeSponsor.Schema.Theme, :count, :id) == 0
    end

    @tag :admin
    test "edit saved theme", %{conn: conn} do
      theme = insert(:theme)
      conn = get conn, theme_path(conn, :edit, theme)
      assert html_response(conn, 200) =~ "Code Sponsor | Edit Theme"
    end

    # @tag :admin
    # test "update saved theme", %{conn: conn} do
    #   theme = insert(:theme)
    #   params = %{
    #     "theme" => %{
    #       "name" => "name",
    #       "body" => "body",
    #       "slug" => "slug"
    #     }
    #   }
    #   saved_theme = Repo.one(CodeSponsor.Schema.Theme)
    #   assert saved_theme.name == theme.name
    #   assert Repo.aggregate(CodeSponsor.Schema.Theme, :count, :id) == 1
    #   conn = patch conn, theme_path(conn, :update, theme), params
    #   assert html_response(conn, 200)
    #   assert Repo.aggregate(CodeSponsor.Schema.Theme, :count, :id) == 1
    #   updated_theme = Repo.one(CodeSponsor.Schema.Theme)
    #   assert updated_theme.name == params["theme"]["name"]
    # end



  end
end
