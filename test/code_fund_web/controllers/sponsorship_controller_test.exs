defmodule CodeFundWeb.SponsorshipControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    users = stub_users()

    objects = %{
      user_campaign: insert(:campaign, user: users.sponsor),
      campaign: insert(:campaign),
      user_creative: insert(:creative, user: users.sponsor),
      creative: insert(:creative),
      property: insert(:property)
    }

    valid_params =
      string_params_with_assocs(:sponsorship, user: nil)
      |> Map.merge(%{
        "bid_amount" => "2.0",
        "override_revenue_rate" => "0.20",
        "campaign_id" => insert(:campaign, user: users.admin).id,
        "creative_id" => insert(:creative, user: users.admin).id
      })

    {:ok, %{valid_params: valid_params, users: users, objects: objects}}
  end

  describe "index" do
    fn conn, _context ->
      get(conn, sponsorship_path(conn, :index))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /Sponsorships")

    test "renders the index as a sponsor", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.sponsor)
      sponsorship = insert(:sponsorship, user: users.sponsor)
      insert(:sponsorship)
      sponsorship = CodeFund.Sponsorships.get_sponsorship!(sponsorship.id)
      conn = get(conn, sponsorship_path(conn, :index))

      assert conn.assigns.sponsorships |> CodeFund.Repo.preload(:user) == [sponsorship]
      assert html_response(conn, 200) =~ "Sponsorships"
    end

    test "renders the index as an admin", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      sponsorship = insert(:sponsorship)
      sponsorship = CodeFund.Sponsorships.get_sponsorship!(sponsorship.id)
      conn = get(conn, sponsorship_path(conn, :index))

      assert conn.assigns.sponsorships |> CodeFund.Repo.preload(:user) == [sponsorship]
      assert html_response(conn, 200) =~ "Sponsorships"
    end
  end

  describe "new" do
    fn conn, _context ->
      get(conn, sponsorship_path(conn, :new))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /sponsorships/new")

    test "renders the new template as a sponsor", %{conn: conn, users: users, objects: objects} do
      conn = assign(conn, :current_user, users.sponsor)
      conn = get(conn, sponsorship_path(conn, :new))

      assert conn.assigns.fields |> Keyword.keys() == [
               :campaign_id,
               :property_id,
               :creative_id,
               :bid_amount,
               :redirect_url,
               :override_revenue_rate
             ]

      assert conn.assigns.fields |> get_in([:campaign_id, :opts, :choices]) == [
               {objects.user_campaign.name, objects.user_campaign.id}
             ]

      assert conn.assigns.fields |> get_in([:creative_id, :opts, :choices]) == [
               {objects.user_creative.name, objects.user_creative.id}
             ]

      assert conn.assigns.fields |> get_in([:property_id, :opts, :choices]) ==
               CodeFund.Properties.list_active_properties()
               |> Framework.Phoenix.Form.Helpers.repo_objects_to_options([:name, :url])

      assert conn.assigns.fields |> get_in([:override_revenue_rate, :type]) == :hidden_input

      assert html_response(conn, 200) =~ "Sponsorship"
    end

    test "renders the new template as a admin", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      conn = get(conn, sponsorship_path(conn, :new))

      assert conn.assigns.fields |> Keyword.keys() == [
               :campaign_id,
               :property_id,
               :creative_id,
               :bid_amount,
               :redirect_url,
               :override_revenue_rate
             ]

      assert conn.assigns.fields |> get_in([:override_revenue_rate, :type]) == :currency_input

      assert html_response(conn, 200) =~ "Sponsorship"
    end
  end

  describe "create" do
    fn conn, context ->
      post(
        conn,
        sponsorship_path(conn, :create, %{"params" => %{"sponsorship" => context.valid_params}})
      )
    end
    |> behaves_like([:authenticated, :sponsor], "POST /sponsorships/create")

    test "creates a sponsorship", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(
          conn,
          sponsorship_path(conn, :create, %{"params" => %{"sponsorship" => valid_params}})
        )

      assert conn |> Phoenix.Controller.get_flash(:info) == "Sponsorship created successfully."

      assert redirected_to(conn, 302) ==
               sponsorship_path(conn, :show, CodeFund.Schema.Sponsorship |> CodeFund.Repo.one())
    end

    test "returns an error on invalid params for a sponsorship", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(
          conn,
          sponsorship_path(conn, :create, %{
            "params" => %{"sponsorship" => valid_params |> Map.put("bid_amount", nil)}
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.fields |> Keyword.keys() == [
               :campaign_id,
               :property_id,
               :creative_id,
               :bid_amount,
               :redirect_url,
               :override_revenue_rate
             ]

      assert conn.assigns.changeset.errors == [
               bid_amount: {"can't be blank", [validation: :required]}
             ]

      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "show" do
    fn conn, _context ->
      get(conn, sponsorship_path(conn, :show, insert(:sponsorship)))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /sponsorships/:id")

    test "renders the show template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      sponsorship = insert(:sponsorship)
      conn = get(conn, sponsorship_path(conn, :show, sponsorship))

      assert html_response(conn, 200) =~ "Sponsorship"
      assert html_response(conn, 200) =~ sponsorship.bid_amount |> Decimal.to_string()
    end
  end

  describe "edit" do
    fn conn, _context ->
      get(conn, sponsorship_path(conn, :edit, insert(:sponsorship)))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /sponsorships/edit")

    test "renders the edit template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      sponsorship = insert(:sponsorship)
      conn = get(conn, sponsorship_path(conn, :edit, sponsorship))

      assert html_response(conn, 200) =~ "Sponsorship"
      assert html_response(conn, 200) =~ sponsorship.bid_amount |> Decimal.to_string()

      assert conn.assigns.fields |> Keyword.keys() == [
               :campaign_id,
               :property_id,
               :creative_id,
               :bid_amount,
               :redirect_url,
               :override_revenue_rate
             ]
    end
  end

  describe "update" do
    fn conn, _context ->
      patch(
        conn,
        sponsorship_path(conn, :update, insert(:sponsorship), %{"bid_amount" => "bid_amount"})
      )
    end
    |> behaves_like([:authenticated, :sponsor], "PATCH /sponsorships/update")

    test "updates a sponsorship", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      campaign = insert(:campaign, user: users.admin)
      creative = insert(:creative, user: users.admin)

      sponsorship =
        insert(:sponsorship, %{campaign: campaign, creative: creative, user: users.admin})

      sponsorship_params =
        string_params_with_assocs(:sponsorship, %{
          campaign: campaign,
          creative: creative,
          user: users.admin,
          bid_amount: "100.00"
        })

      conn =
        patch(
          conn,
          sponsorship_path(conn, :update, sponsorship, %{
            "params" => %{"sponsorship" => sponsorship_params}
          })
        )

      assert redirected_to(conn, 302) == sponsorship_path(conn, :show, sponsorship)

      assert CodeFund.Sponsorships.get_sponsorship!(sponsorship.id).bid_amount ==
               Decimal.new("100.00")
    end

    test "returns an error on invalid params for a sponsorship", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.admin)

      campaign = insert(:campaign, user: users.admin)
      creative = insert(:creative, user: users.admin)

      sponsorship =
        insert(:sponsorship, %{campaign: campaign, creative: creative, user: users.admin})

      conn =
        patch(
          conn,
          sponsorship_path(conn, :update, sponsorship, %{
            "params" => %{"sponsorship" => valid_params |> Map.put("bid_amount", nil)}
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.fields |> Keyword.keys() == [
               :campaign_id,
               :property_id,
               :creative_id,
               :bid_amount,
               :redirect_url,
               :override_revenue_rate
             ]

      assert conn.assigns.changeset.errors == [
               bid_amount: {"can't be blank", [validation: :required]}
             ]

      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "delete" do
    fn conn, _context ->
      delete(conn, sponsorship_path(conn, :delete, insert(:sponsorship)))
    end
    |> behaves_like([:authenticated, :sponsor], "DELETE /sponsorships/:id")

    test "deletes the sponsorship and redirects to index", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      sponsorship = insert(:sponsorship)
      conn = delete(conn, sponsorship_path(conn, :delete, sponsorship))

      assert conn |> Phoenix.Controller.get_flash(:info) == "Sponsorship deleted successfully."
      assert redirected_to(conn, 302) == sponsorship_path(conn, :index)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.Sponsorships.get_sponsorship!(sponsorship.id).bid_amount == nil
                   end
    end
  end
end
