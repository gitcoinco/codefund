defmodule CodeSponsorWeb.SponsorshipControllerTest do
  use CodeSponsorWeb.ConnCase

  describe "Sponsorship Controller" do
    test "index should list sponsorships", %{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      insert_list(25, :sponsorship)
      conn = assign conn, :current_user, user
      conn = get conn, sponsorship_path(conn, :index)
      assert html_response(conn, 200) =~ "Sponsorships"
    end

    test "new should sponsorship form", %{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      insert_list(25, :sponsorship)
      conn = assign conn, :current_user, user
      conn = get conn, sponsorship_path(conn, :new)
      assert html_response(conn, 200)
    end

    test "create should save sponsorship", %{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      conn = assign conn, :current_user, user
      params =  %{
        "sponsorship" => %{
          "bid_amount" => 4.3,
          "redirect_url" => "https://redirec.li"
        }
      }
      conn = post conn, sponsorship_path(conn, :create), params
      assert html_response(conn, 200)
    end

    # test "update should edit a sponsorship", %{conn: conn} do
    #   user = insert(:user, %{roles: ["sponsor"]})
    #   conn = assign conn, :current_user, user
    #   sponsorship = insert(:sponsorship)
    #   params =  %{
    #     "sponsorship" => %{
    #       "bid_amount" => 4.3,
    #       "redirect_url" => "https://redirec.li"
    #     }
    #   }
    #   conn = patch conn, sponsorship_path(conn, :update, sponsorship), params
    #   assert html_response(conn, 200)
    #   updated_sponsorship = Repo.one(CodeSponsor.Schema.Sponsorship)
    #   assert updated_sponsorship.redirect_url == params["sponsorship"]["redirect_url"]
    # end

    test "show should show a sponsorship", %{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      sponsorship = insert(:sponsorship)
      conn = assign conn, :current_user, user
      conn = get conn, sponsorship_path(conn, :show, sponsorship)
      assert html_response(conn, 200) =~ "Edit Sponsorship"
    end

    test " edit should show a sponsorship edit form", %{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      sponsorship = insert(:sponsorship)
      conn = assign conn, :current_user, user
      conn = get conn, sponsorship_path(conn, :edit, sponsorship)
      assert html_response(conn, 200) =~ "Edit Sponsorship"
    end

    test "deletes a sponsorship", %{conn: conn} do
      user = insert(:user, %{roles: ["admin"]})
      sponsorship = insert(:sponsorship)
      conn = assign conn, :current_user, user
      assert Repo.aggregate(CodeSponsor.Schema.Sponsorship, :count, :id) == 1
      conn = delete conn, sponsorship_path(conn, :delete, sponsorship)
      assert Repo.aggregate(CodeSponsor.Schema.Sponsorship, :count, :id) == 0
    end
  end
end
