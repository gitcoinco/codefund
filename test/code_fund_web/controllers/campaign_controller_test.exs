defmodule CodeFundWeb.CampaignControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    valid_params =
      string_params_with_assocs(:campaign)
      |> Map.merge(%{
        "ecpm" => "2.0",
        "budget_daily_amount" => "25.0",
        "total_spend" => "25.0",
        "start_date" => "2018-10-14",
        "end_date" => "2018-10-14",
        "override_revenue_rate" => "0.00"
      })

    {:ok, %{valid_params: valid_params, users: stub_users()}}
  end

  describe "index" do
    fn conn, _context ->
      get(conn, campaign_path(conn, :index))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /Campaigns")

    test "renders the index as a sponsor", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.sponsor)

      campaign = insert(:campaign, user: users.sponsor)

      insert(:campaign)
      campaign = CodeFund.Campaigns.get_campaign!(campaign.id)
      conn = get(conn, campaign_path(conn, :index))

      assert conn.assigns.campaigns == [campaign]
      assert html_response(conn, 200) =~ "Campaigns"
    end

    test "renders the index as an admin", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      campaign = insert(:campaign)
      campaign = CodeFund.Campaigns.get_campaign!(campaign.id)
      conn = get(conn, campaign_path(conn, :index))

      assert conn.assigns.campaigns == [campaign]
      assert html_response(conn, 200) =~ "Campaigns"
    end
  end

  describe "new" do
    fn conn, _context ->
      get(conn, campaign_path(conn, :new))
    end
    |> behaves_like([:authenticated, :admin], "GET /campaigns/new")

    test "renders the new template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      conn = get(conn, campaign_path(conn, :new))

      assert html_response(conn, 200) =~ "Campaign"
    end
  end

  describe "duplicate" do
    fn conn, _context ->
      campaign =
        insert(:campaign,
          status: CodeFund.Campaigns.statuses()[:Active],
          name: "Test Campaign",
          start_date: ~N[2018-09-18 21:26:24.479855],
          end_date: ~N[2018-09-18 21:26:24.479855]
        )

      post(conn, campaign_campaign_path(conn, :duplicate, campaign))
    end
    |> behaves_like([:authenticated, :admin], "POST /campaigns/:campaign_id/duplicate")

    test "duplicates a campaign and redirects to the edit page for that campaign", %{
      conn: conn,
      users: users
    } do
      campaign =
        insert(:campaign,
          status: CodeFund.Campaigns.statuses()[:Active],
          name: "Test Campaign",
          start_date: ~N[2018-09-18 21:26:24.479855],
          end_date: ~N[2018-09-18 21:26:24.479855]
        )

      conn = assign(conn, :current_user, users.admin)
      conn = post(conn, campaign_campaign_path(conn, :duplicate, campaign))

      duplicated_campaign = CodeFund.Campaigns.get_campaign_by_name!("Copy Of Test Campaign")

      assert redirected_to(conn, 302) == campaign_path(conn, :edit, duplicated_campaign)
      assert conn |> Phoenix.Controller.get_flash(:info) == "Campaign duplicated successfully."
    end
  end

  describe "create" do
    fn conn, context ->
      post(
        conn,
        campaign_path(conn, :create, %{"params" => %{"campaign" => context.valid_params}})
      )
    end
    |> behaves_like([:authenticated, :admin], "POST /campaigns/create")

    test "creates a campaign", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)

      params = %{
        "ecpm" => "2.0",
        "budget_daily_amount" => "25.0",
        "total_spend" => "25.0",
        "name" => "Test Campaign",
        "start_date" => "2018-10-14",
        "end_date" => "2018-10-14",
        "impression_count" => 800_000,
        "redirect_url" => "https://example.com/0",
        "creative_id" => insert(:creative).id,
        "user_id" => users.admin.id,
        "status" => 2
      }

      conn = post(conn, campaign_path(conn, :create, %{"params" => %{"campaign" => params}}))

      assert redirected_to(conn, 302) ==
               campaign_path(conn, :show, CodeFund.Schema.Campaign |> CodeFund.Repo.one())

      assert conn |> Phoenix.Controller.get_flash(:info) == "Campaign created successfully."
    end

    test "returns an error on invalid params for a campaign", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(
          conn,
          campaign_path(conn, :create, %{
            "params" => %{
              "campaign" =>
                valid_params
                |> Map.merge(%{"name" => nil})
            }
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [name: {"can't be blank", [validation: :required]}]
      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "show" do
    fn conn, _context ->
      get(conn, campaign_path(conn, :show, insert(:campaign)))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /campaigns/:id")

    test "renders the show template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      campaign = insert(:campaign)
      conn = get(conn, campaign_path(conn, :show, campaign))

      assert html_response(conn, 200) =~ "Campaign"
      assert html_response(conn, 200) =~ campaign.name
    end
  end

  describe "edit" do
    fn conn, _context ->
      get(conn, campaign_path(conn, :edit, insert(:campaign)))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /campaigns/edit")

    test "renders the edit template as an admin", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      campaign = insert(:campaign, user: users.admin)
      conn = get(conn, campaign_path(conn, :edit, campaign))

      assert html_response(conn, 200) =~ "Campaign"
      assert html_response(conn, 200) =~ campaign.name

      assert conn.assigns.fields |> Keyword.keys() |> Enum.sort == [
               :active_dates,
               :audience_id,
               :budget_daily_amount,
               :creative_id,
               :ecpm,
               :end_date,
               :included_countries,
               :name,
               :redirect_url,
               :start_date,
               :status,
               :total_spend,
               :us_hours_only,
               :user_id,
               :weekdays_only,
             ]
    end

    test "renders the edit template as a sponsor", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.sponsor)
      campaign = insert(:campaign)
      conn = get(conn, campaign_path(conn, :edit, campaign))

      assert html_response(conn, 200) =~ "Campaign"
      assert html_response(conn, 200) =~ campaign.name

      assert conn.assigns.fields |> Keyword.keys() |> Enum.sort == [
               :active_dates,
               :budget_daily_amount,
               :creative_id,
               :end_date,
               :name,
               :redirect_url,
               :start_date,
               :status,
             ]
    end
  end

  describe "update" do
    fn conn, _context ->
      patch(conn, campaign_path(conn, :update, insert(:campaign), %{"name" => "name"}))
    end
    |> behaves_like([:authenticated, :sponsor], "PATCH /campaigns/update")

    test "updates a campaign", %{conn: conn, users: users, valid_params: valid_params} do
      campaign = insert(:campaign)
      conn = assign(conn, :current_user, users.admin)

      conn =
        patch(
          conn,
          campaign_path(conn, :update, campaign, %{
            "params" => %{"campaign" => valid_params |> Map.put("name", "New Name")}
          })
        )

      assert redirected_to(conn, 302) == campaign_path(conn, :show, campaign)
      assert CodeFund.Campaigns.get_campaign!(campaign.id).name == "New Name"
    end

    test "returns an error on invalid params for a campaign", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      campaign = insert(:campaign)
      conn = assign(conn, :current_user, users.sponsor)

      conn =
        patch(
          conn,
          campaign_path(conn, :update, campaign, %{
            "params" => %{"campaign" => valid_params |> Map.put("name", nil)}
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [name: {"can't be blank", [validation: :required]}]
      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "delete" do
    fn conn, _context ->
      delete(conn, campaign_path(conn, :delete, insert(:campaign)))
    end
    |> behaves_like([:authenticated, :sponsor], "DELETE /campaigns/:id")

    test "deletes the campaign and redirects to index", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      campaign = insert(:campaign)
      conn = delete(conn, campaign_path(conn, :delete, campaign))

      assert conn |> Phoenix.Controller.get_flash(:info) == "Campaign deleted successfully."
      assert redirected_to(conn, 302) == campaign_path(conn, :index)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.Campaigns.get_campaign!(campaign.id).name == nil
                   end
    end
  end
end
