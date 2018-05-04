defmodule CodeFundWeb.User.DistributionControllerTest do
  use CodeFundWeb.ConnCase
  import Ecto.Query
  import CodeFund.Factory

  setup do
    users = stub_users()

    distribution =
      insert(
        :distribution,
        click_range_start: ~N[2018-01-01 00:00:00],
        click_range_end: ~N[2018-01-01 00:00:00]
      )

    property = insert(:property, user: users.developer)

    click_1 =
      insert(
        :click,
        property: property,
        inserted_at: ~N[2018-01-02 00:00:00],
        distribution_amount: "2.00",
        status: 1
      )

    click_2 =
      insert(
        :click,
        property: property,
        inserted_at: ~N[2018-01-02 00:00:00],
        distribution_amount: "2.00",
        status: 1
      )

    click_3 =
      insert(
        :click,
        property: insert(:property, user: users.developer),
        inserted_at: ~N[2018-01-04 00:00:00],
        distribution_amount: "2.00"
      )

    click_4 =
      insert(
        :click,
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
       clicks: [click_1: click_1, click_2: click_2, click_3: click_3, click_4: click_4]
     }}
  end

  def shared_assigns_test(assigns, user) do
    assert assigns.schema == "Distribution"
    assert assigns.nested == ["User"]
    assert assigns.action == :create

    assert assigns.clicks == %{
             "click_count" => 2,
             "distribution_amount" => Decimal.new("4.00")
           }

    assert assigns.user == user
    assert assigns.start_date == "2018-01-01"
    assert assigns.end_date == "2018-01-03"
    assert assigns.associations == [user.id]
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
                "click_range_end" => "2018-01-03",
                "click_range_start" => "2018-01-01"
              }
            }
          })
        )

      assert html_response(authed_conn, 200) =~
               "New Distribution for #{users.developer.first_name} #{users.developer.last_name}"

      shared_assigns_test(authed_conn.assigns, users.developer)
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
              "click_range_end" => "2001-01-01",
              "click_range_start" => "2001-01-01"
            }
          }
        })
      )
    end
    |> behaves_like([:authenticated, :admin], "GET /users/user_id/distributions/search")

    test "successfully creates a distribution", %{
      users: users,
      authed_conn: authed_conn,
      clicks: clicks
    } do
      authed_conn =
        post(
          authed_conn,
          user_distribution_path(authed_conn, :create, users.developer, %{
            "params" => %{
              "distribution" => %{
                "click_range_end" => "2018-01-03",
                "click_range_start" => "2018-01-01",
                "amount" => "5.00",
                "currency" => "usd"
              }
            }
          })
        )

      distribution = from(d in CodeFund.Schema.Distribution) |> CodeFund.Repo.all() |> List.last()
      assert distribution.click_range_start == ~N[2018-01-01 00:00:00.000000]
      assert distribution.click_range_end == ~N[2018-01-03 00:00:00.000000]
      assert CodeFund.Clicks.get_click!(clicks[:click_1].id).distribution_id == distribution.id
      assert CodeFund.Clicks.get_click!(clicks[:click_2].id).distribution_id == distribution.id
      assert CodeFund.Clicks.get_click!(clicks[:click_3].id).distribution_id == nil
      assert CodeFund.Clicks.get_click!(clicks[:click_4].id).distribution_id == nil

      assert redirected_to(authed_conn, 302) ==
               user_distribution_path(authed_conn, :show, users.developer, distribution)

      shared_assigns_test(authed_conn.assigns, users.developer)
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
                "click_range_end" => "2018-01-03",
                "click_range_start" => "2018-01-01",
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
      shared_assigns_test(authed_conn.assigns, users.developer)
    end
  end
end
