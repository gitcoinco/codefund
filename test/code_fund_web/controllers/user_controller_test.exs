defmodule CodeFundWeb.UserControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    valid_params = string_params_for(:user, %{revenue_rate: "0.60"})
    {:ok, %{valid_params: valid_params, users: stub_users()}}
  end

  describe "index" do
    fn conn, _context ->
      get(conn, user_path(conn, :index))
    end
    |> behaves_like([:authenticated, :admin], "GET /users")

    test "lists users", %{
      conn: conn,
      users: users
    } do
      conn = assign(conn, :current_user, users.admin)

      conn = get(conn, user_path(conn, :index))
      assert html_response(conn, 200)

      assert conn.assigns.users ==
               [
                 users.developer,
                 users.sponsor,
                 users.admin
               ]
               |> CodeFund.Repo.preload([:properties])
    end
  end

  describe "show" do
    fn conn, context ->
      get(conn, user_path(conn, :show, context.users.sponsor))
    end
    |> behaves_like([:authenticated, :owned_unless_admin], "GET /user/:id")

    test "renders the show template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.developer)
      conn = get(conn, user_path(conn, :show, users.developer))

      assert html_response(conn, 200) =~ "User"
      assert html_response(conn, 200) =~ users.developer.first_name
    end
  end

  describe "edit" do
    fn conn, context ->
      get(conn, user_path(conn, :edit, context.users.sponsor))
    end
    |> behaves_like([:authenticated, :owned_unless_admin], "GET /user/:id/edit")

    test "renders the edit template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.developer)
      conn = get(conn, user_path(conn, :edit, users.developer))

      assert html_response(conn, 200) =~ "User"
      assert html_response(conn, 200) =~ users.developer.first_name
    end
  end

  describe "update" do
    fn conn, context ->
      patch(
        conn,
        user_path(conn, :update, context.users.sponsor, %{
          "params" => %{"user" => context.valid_params |> Map.put("first_name", "New Name")}
        })
      )
    end
    |> behaves_like([:authenticated, :owned_unless_admin], "PATCH /user/:id")

    test "updates a user", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.developer)

      conn =
        patch(
          conn,
          user_path(conn, :update, users.developer, %{
            "params" => %{"user" => valid_params |> Map.put("first_name", "New Name")}
          })
        )

      assert redirected_to(conn, 302) == user_path(conn, :show, users.developer)
      assert CodeFund.Users.get_user!(users.developer.id).first_name == "New Name"
    end

    test "returns an error on invalid params for a user", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.developer)

      conn =
        patch(
          conn,
          user_path(conn, :update, users.developer, %{
            "params" => %{"user" => valid_params |> Map.put("first_name", nil)}
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [
               first_name: {"can't be blank", [validation: :required]}
             ]

      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "masquerade" do
    fn conn, context ->
      get(conn, user_path(conn, :masquerade, context.users.developer))
    end
    |> behaves_like([:authenticated, :admin], "GET /users/:id/masquerade")

    test "it allows admin users to masquerade", %{
      conn: conn,
      users: users
    } do
      conn = assign(conn, :current_user, users.admin)

      conn = get(conn, user_path(conn, :masquerade, users.sponsor))
      assert redirected_to(conn, 302) == "/dashboard"
      assert get_flash(conn, :notice) == "You have successfully begun masquerading."
      assert Plug.Conn.get_session(conn, "admin_user") == users.admin
    end
  end

  describe "end_masquerade" do
    fn conn, _context ->
      get(conn, user_path(conn, :end_masquerade))
    end
    |> behaves_like([:authenticated], "GET /users/end_masquerade")

    test "it allows admin users to return to their previous user login", %{
      conn: conn,
      users: users
    } do
      conn = assign(conn, :current_user, users.admin)

      conn = get(conn, user_path(conn, :end_masquerade))
      assert redirected_to(conn, 302) == "/dashboard"
      assert get_flash(conn, :notice) == "You have successfully ended masquerading."
      assert Plug.Conn.get_session(conn, "admin_user") == nil
    end
  end
end
