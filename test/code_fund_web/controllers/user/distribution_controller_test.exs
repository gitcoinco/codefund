defmodule CodeFundWeb.User.DistributionControllerTest do
  use CodeFundWeb.ConnCase
  import Ecto.Query
  import CodeFund.Factory

  setup do
    users = stub_users()

    distribution =
      insert(
        :distribution,
        range_start: ~N[2018-01-01 00:00:00],
        range_end: ~N[2018-01-01 00:00:00]
      )

    property = insert(:property, user: users.developer)

    impression_1 =
      insert(
        :impression,
        property: property,
        inserted_at: ~N[2018-01-02 00:00:00],
        distribution_amount: "2.00"
      )

    impression_2 =
      insert(
        :impression,
        property: property,
        inserted_at: ~N[2018-01-02 00:00:00],
        distribution_amount: "2.00"
      )

    impression_3 =
      insert(
        :impression,
        property: insert(:property, user: users.developer),
        inserted_at: ~N[2018-01-04 00:00:00],
        distribution_amount: "2.00"
      )

    impression_4 =
      insert(
        :impression,
        property: insert(:property, user: users.admin),
        inserted_at: ~N[2018-01-02 00:00:00],
        distribution_amount: "2.00"
      )

    authed_conn = assign(build_conn(), :current_user, users.admin)

    {:ok,
     %{
       authed_conn: authed_conn,
       users: users,
       distribution: distribution,
       impressions: [
         impression_1: impression_1,
         impression_2: impression_2,
         impression_3: impression_3,
         impression_4: impression_4
       ]
     }}
  end

  def shared_assigns_test(conn, user) do
    assert conn.private.controller_config.schema == "Distribution"
    assert conn.private.controller_config.nested == ["User"]
    assert conn.assigns.action == :create

    assert conn.assigns.impressions == %{
             "impression_count" => 2,
             "distribution_amount" => Decimal.new("4.000000000000")
           }

    assert conn.assigns.user == user
    assert conn.assigns.start_date == "2018-01-01"
    assert conn.assigns.end_date == "2018-01-03"
    assert conn.assigns.associations == [user.id]
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
      authed_conn =
        get(
          authed_conn,
          user_distribution_path(authed_conn, :new, users.developer, %{
            "params" => %{
              "distribution" => %{
                "range_end" => "2018-01-03",
                "range_start" => "2018-01-01"
              }
            }
          })
        )

      assert html_response(authed_conn, 200) =~
               "New Distribution for #{users.developer.first_name} #{users.developer.last_name}"

      shared_assigns_test(authed_conn, users.developer)
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

  describe "create" do
    fn conn, context ->
      post(
        conn,
        user_distribution_path(conn, :create, context.users.developer, %{
          "params" => %{
            "distribution" => %{
              "range_end" => "2001-01-01",
              "range_start" => "2001-01-01"
            }
          }
        })
      )
    end
    |> behaves_like([:authenticated, :admin], "GET /users/user_id/distributions/search")

    test "successfully creates a distribution", %{
      users: users,
      authed_conn: authed_conn,
      impressions: impressions
    } do
      authed_conn =
        post(
          authed_conn,
          user_distribution_path(authed_conn, :create, users.developer, %{
            "params" => %{
              "distribution" => %{
                "range_end" => "2018-01-03",
                "range_start" => "2018-01-01",
                "amount" => "5.00",
                "currency" => "usd"
              }
            }
          })
        )

      distribution = from(d in CodeFund.Schema.Distribution) |> CodeFund.Repo.all() |> List.last()
      assert distribution.range_start == ~N[2018-01-01 00:00:00.000000]
      assert distribution.range_end == ~N[2018-01-03 00:00:00.000000]

      assert CodeFund.Impressions.get_impression!(impressions[:impression_1].id).distribution_id ==
               distribution.id

      assert CodeFund.Impressions.get_impression!(impressions[:impression_2].id).distribution_id ==
               distribution.id

      assert CodeFund.Impressions.get_impression!(impressions[:impression_3].id).distribution_id ==
               nil

      assert CodeFund.Impressions.get_impression!(impressions[:impression_4].id).distribution_id ==
               nil

      assert redirected_to(authed_conn, 302) ==
               user_distribution_path(authed_conn, :show, users.developer, distribution)

      shared_assigns_test(authed_conn, users.developer)
    end

    test "returns an error on invalid params", %{
      users: users,
      authed_conn: authed_conn
    } do
      authed_conn =
        post(
          authed_conn,
          user_distribution_path(authed_conn, :create, users.developer, %{
            "params" => %{
              "distribution" => %{
                "range_end" => "2018-01-03",
                "range_start" => "2018-01-01",
                "currency" => "usd"
              }
            }
          })
        )

      assert html_response(authed_conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert authed_conn.assigns.changeset.errors == [
               amount: {"can't be blank", [validation: :required]}
             ]

      assert authed_conn.private.phoenix_template == "form_container.html"
      shared_assigns_test(authed_conn, users.developer)
    end
  end
end
