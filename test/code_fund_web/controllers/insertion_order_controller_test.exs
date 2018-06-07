defmodule CodeFundWeb.InsertionOrderControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    valid_params = string_params_with_assocs(:insertion_order)

    {:ok, %{valid_params: valid_params, users: stub_users()}}
  end

  describe "index" do
    fn conn, _context ->
      get(conn, insertion_order_path(conn, :index))
    end
    |> behaves_like([:authenticated, :admin], "GET /InsertionOrders")

    test "renders the index as an admin", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      insertion_order = insert(:insertion_order)
      insertion_order = CodeFund.InsertionOrders.get_insertion_order!(insertion_order.id)
      conn = get(conn, insertion_order_path(conn, :index))

      assert conn.assigns.insertion_orders == [insertion_order]
      assert html_response(conn, 200) =~ "Insertion Orders"
    end
  end

  describe "new" do
    fn conn, _context ->
      get(conn, insertion_order_path(conn, :new))
    end
    |> behaves_like([:authenticated, :admin], "GET /insertion_orders/new")

    test "renders the new template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      conn = get(conn, insertion_order_path(conn, :new))

      assert html_response(conn, 200) =~ "InsertionOrder"
    end
  end

  describe "create" do
    fn conn, context ->
      post(
        conn,
        insertion_order_path(conn, :create, %{
          "params" => %{"insertion_order" => context.valid_params}
        })
      )
    end
    |> behaves_like([:authenticated, :admin], "POST /insertion_orders/create")

    test "creates a insertion_order", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(
          conn,
          insertion_order_path(conn, :create, %{
            "params" => %{
              "insertion_order" => valid_params |> Map.merge(%{"billing_cycle" => "2018-01-01"})
            }
          })
        )

      assert redirected_to(conn, 302) ==
               insertion_order_path(
                 conn,
                 :show,
                 CodeFund.Schema.InsertionOrder |> CodeFund.Repo.one()
               )

      assert conn |> Phoenix.Controller.get_flash(:info) == "InsertionOrder created successfully."
    end

    test "returns an error on invalid params for a insertion_order", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(
          conn,
          insertion_order_path(conn, :create, %{
            "params" => %{
              "insertion_order" =>
                valid_params
                |> Map.merge(%{"impression_count" => nil, "billing_cycle" => "2018-01-01"})
            }
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [
               impression_count: {"can't be blank", [validation: :required]}
             ]

      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "show" do
    fn conn, _context ->
      get(conn, insertion_order_path(conn, :show, insert(:insertion_order)))
    end
    |> behaves_like([:authenticated, :admin], "GET /insertion_orders/:id")

    test "renders the show template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      insertion_order = insert(:insertion_order)
      conn = get(conn, insertion_order_path(conn, :show, insertion_order))

      assert html_response(conn, 200) =~ "Insertion Orders"
      assert html_response(conn, 200) =~ insertion_order.audience.name
    end
  end

  describe "edit" do
    fn conn, _context ->
      get(conn, insertion_order_path(conn, :edit, insert(:insertion_order)))
    end
    |> behaves_like([:authenticated, :admin], "GET /insertion_orders/edit")

    test "renders the edit template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      insertion_order = insert(:insertion_order)
      conn = get(conn, insertion_order_path(conn, :edit, insertion_order))

      assert html_response(conn, 200) =~ "Insertion Orders"
      assert html_response(conn, 200) =~ insertion_order.audience.name
    end
  end

  describe "update" do
    fn conn, _context ->
      patch(
        conn,
        insertion_order_path(conn, :update, insert(:insertion_order), %{"name" => "name"})
      )
    end
    |> behaves_like([:authenticated, :admin], "PATCH /insertion_orders/update")

    test "updates a insertion_order", %{conn: conn, users: users} do
      insertion_order =
        insert(:insertion_order, audience: insert(:audience), impression_count: 10)

      conn = assign(conn, :current_user, users.admin)

      conn =
        patch(
          conn,
          insertion_order_path(conn, :update, insertion_order, %{
            "params" => %{
              "insertion_order" => %{"impression_count" => 50, "billing_cycle" => "2018-01-01"}
            }
          })
        )

      assert redirected_to(conn, 302) == insertion_order_path(conn, :show, insertion_order)

      assert CodeFund.InsertionOrders.get_insertion_order!(insertion_order.id).impression_count ==
               50
    end

    test "returns an error on invalid params for a insertion_order", %{
      conn: conn,
      users: users
    } do
      insertion_order = insert(:insertion_order, audience: insert(:audience))
      conn = assign(conn, :current_user, users.admin)

      conn =
        patch(
          conn,
          insertion_order_path(conn, :update, insertion_order, %{
            "params" => %{
              "insertion_order" => %{"impression_count" => nil, "billing_cycle" => "2018-01-01"}
            }
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [
               impression_count: {"can't be blank", [validation: :required]}
             ]

      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "delete" do
    fn conn, _context ->
      delete(conn, insertion_order_path(conn, :delete, insert(:insertion_order)))
    end
    |> behaves_like([:authenticated, :admin], "DELETE /insertion_orders/:id")

    test "deletes the insertion_order and redirects to index", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      insertion_order = insert(:insertion_order)
      conn = delete(conn, insertion_order_path(conn, :delete, insertion_order))

      assert conn |> Phoenix.Controller.get_flash(:info) == "InsertionOrder deleted successfully."
      assert redirected_to(conn, 302) == insertion_order_path(conn, :index)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.InsertionOrders.get_insertion_order!(insertion_order.id).name == nil
                   end
    end
  end
end
