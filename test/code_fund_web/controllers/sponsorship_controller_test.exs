defmodule CodeFundWeb.SponsorshipControllerTest do
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

    test "renders the new template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      conn = get(conn, sponsorship_path(conn, :new))

      assert html_response(conn, 200) =~ "Sponsorship"
    end
  end

  describe "create" do
    fn conn, context ->
      post(conn, sponsorship_path(conn, :create, %{"sponsorship" => context.valid_params}))
    end
    |> behaves_like([:authenticated, :sponsor], "POST /sponsorships/create")

    test "creates a sponsorship", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.admin)
      conn = post(conn, sponsorship_path(conn, :create, %{"sponsorship" => valid_params}))
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
            "sponsorship" => valid_params |> Map.delete("bid_amount")
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.form.errors == [bid_amount: ["can't be blank"]]
      assert conn.private.phoenix_template == "new.html"
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
          sponsorship_path(conn, :update, sponsorship, %{"sponsorship" => sponsorship_params})
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

      conn =
        post(
          conn,
          sponsorship_path(conn, :create, %{
            "sponsorship" => valid_params |> Map.delete("bid_amount")
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.form.errors == [bid_amount: ["can't be blank"]]
      assert conn.private.phoenix_template == "new.html"
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
