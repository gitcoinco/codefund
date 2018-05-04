defmodule CodeFundWeb.User.DistributionControllerTest do
  use CodeFundWeb.ConnCase
  import CodeFund.Factory

  setup do
    users = stub_users()

    distribution =
      insert(
        :distribution,
        click_range_start: ~N[2018-01-01 00:00:00],
        click_range_end: ~N[2018-01-01 00:00:00]
      )

    authed_conn = assign(build_conn(), :current_user, users.admin)
    {:ok, %{authed_conn: authed_conn, users: users, distribution: distribution}}
  end

  describe "show" do
    fn conn, context ->
      get(conn, user_distribution_path(conn, :show, context.users.admin, context.distribution))
    end
    |> behaves_like([:authenticated, :admin], "GET /users/user_id/distributions/id/show")

    test "it redirects to the users index", %{
      authed_conn: authed_conn,
      users: users,
      distribution: distribution
    } do
      conn =
        get(
          authed_conn,
          user_distribution_path(authed_conn, :show, users.developer, distribution)
        )

      assert redirected_to(conn, 302) == user_path(conn, :index)
    end
  end

  describe "new" do
    fn conn, context ->
      get(conn, user_distribution_path(conn, :new, context.users.developer))
    end
    |> behaves_like([:authenticated, :admin], "GET /users/user_id/distributions/new")

    test "shows the distribution new page for a developer account", %{
      users: users,
      authed_conn: authed_conn
    } do
      property = insert(:property, user: users.developer)

      insert(
        :click,
        property: property,
        inserted_at: ~N[2018-01-02 00:00:00],
        distribution_amount: "2.00",
        status: 1
      )

      insert(
        :click,
        property: property,
        inserted_at: ~N[2018-01-02 00:00:00],
        distribution_amount: "2.00",
        status: 1
      )

      insert(
        :click,
        property: insert(:property, user: users.developer),
        inserted_at: ~N[2018-01-04 00:00:00],
        distribution_amount: "2.00"
      )

      insert(
        :click,
        property: insert(:property, user: users.admin),
        inserted_at: ~N[2018-01-02 00:00:00],
        distribution_amount: "2.00"
      )

      authed_conn =
        get(
          authed_conn,
          user_distribution_path(authed_conn, :new, users.developer, %{
            "params" => %{
              "distribution" => %{
                "click_range_end" => "2018-01-03",
                "click_range_start" => "2018-01-01"
              }
            }
          })
        )

      assert authed_conn.assigns.schema == "Distribution"
      assert authed_conn.assigns.nested == ["User"]
      assert authed_conn.assigns.action == :create

      assert authed_conn.assigns.clicks == %{
               "click_count" => 2,
               "distribution_amount" => Decimal.new("4.00")
             }

      assert authed_conn.assigns.user == users.developer
      assert authed_conn.assigns.start_date == "2018-01-01"
      assert authed_conn.assigns.end_date == "2018-01-03"
      assert authed_conn.assigns.associations == [users.developer.id]

      assert html_response(authed_conn, 200) =~
               "New Distribution for #{users.developer.first_name} #{users.developer.last_name}"
    end
  end

  describe "search" do
    fn conn, context ->
      get(conn, user_distribution_path(conn, :search, context.users.developer))
    end
    |> behaves_like([:authenticated, :admin], "GET /users/user_id/distributions/search")

    test "shows the distribution search page for a developer account", %{
      users: users,
      authed_conn: authed_conn
    } do
      authed_conn =
        get(authed_conn, user_distribution_path(authed_conn, :search, users.developer))

      assert html_response(authed_conn, 200) =~
               "Make a Distribution for #{users.developer.first_name} #{users.developer.last_name}"
    end
  end
end
