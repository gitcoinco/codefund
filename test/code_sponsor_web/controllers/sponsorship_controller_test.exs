defmodule CodeSponsorWeb.SponsorshipControllerTest do
  use CodeSponsorWeb.ConnCase

  alias CodeSponsor.Sponsorships

  @create_attrs %{bid_amount_cents: 42}
  @update_attrs %{bid_amount_cents: 43}
  @invalid_attrs %{bid_amount_cents: nil}

  def fixture(:sponsorship) do
    {:ok, sponsorship} = Sponsorships.create_sponsorship(@create_attrs)
    sponsorship
  end

  describe "index" do
    test "lists all sponsorships", %{conn: conn} do
      conn = get conn, sponsorship_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Sponsorships"
    end
  end

  describe "new sponsorship" do
    test "renders form", %{conn: conn} do
      conn = get conn, sponsorship_path(conn, :new)
      assert html_response(conn, 200) =~ "New Sponsorship"
    end
  end

  describe "create sponsorship" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, sponsorship_path(conn, :create), sponsorship: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == sponsorship_path(conn, :show, id)

      conn = get conn, sponsorship_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Sponsorship"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, sponsorship_path(conn, :create), sponsorship: @invalid_attrs
      assert html_response(conn, 200) =~ "New Sponsorship"
    end
  end

  describe "edit sponsorship" do
    setup [:create_sponsorship]

    test "renders form for editing chosen sponsorship", %{conn: conn, sponsorship: sponsorship} do
      conn = get conn, sponsorship_path(conn, :edit, sponsorship)
      assert html_response(conn, 200) =~ "Edit Sponsorship"
    end
  end

  describe "update sponsorship" do
    setup [:create_sponsorship]

    test "redirects when data is valid", %{conn: conn, sponsorship: sponsorship} do
      conn = put conn, sponsorship_path(conn, :update, sponsorship), sponsorship: @update_attrs
      assert redirected_to(conn) == sponsorship_path(conn, :show, sponsorship)

      conn = get conn, sponsorship_path(conn, :show, sponsorship)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, sponsorship: sponsorship} do
      conn = put conn, sponsorship_path(conn, :update, sponsorship), sponsorship: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Sponsorship"
    end
  end

  describe "delete sponsorship" do
    setup [:create_sponsorship]

    test "deletes chosen sponsorship", %{conn: conn, sponsorship: sponsorship} do
      conn = delete conn, sponsorship_path(conn, :delete, sponsorship)
      assert redirected_to(conn) == sponsorship_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, sponsorship_path(conn, :show, sponsorship)
      end
    end
  end

  defp create_sponsorship(_) do
    sponsorship = fixture(:sponsorship)
    {:ok, sponsorship: sponsorship}
  end
end
