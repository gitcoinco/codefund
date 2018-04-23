defmodule CodeFundWeb.Property.SponsorshipControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    users = stub_users()

    valid_params =
      string_params_with_assocs(:sponsorship)
      |> Map.merge(%{
        "bid_amount" => "2.0",
        "override_revenue_rate" => "0.20",
        "campaign_id" => insert(:campaign, user: users.admin).id,
        "creative_id" => insert(:creative, user: users.admin).id
      })

    {:ok, %{valid_params: valid_params, users: users}}
  end

  describe "new" do
    fn conn, _context ->
      get(conn, property_sponsorship_path(conn, :new, insert(:property)))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /sponsorships/new")

    test "renders the new template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      property = insert(:property)
      conn = get(conn, property_sponsorship_path(conn, :new, property))

      assert conn.assigns.property == CodeFund.Properties.get_property!(property.id)
      assert html_response(conn, 200) =~ "Add Sponsorship for #{property.name}"
    end
  end
end
