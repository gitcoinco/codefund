defmodule CodeFundWeb.ThemeControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    valid_params = string_params_with_assocs(:theme, template: insert(:template))

    {:ok, %{valid_params: valid_params, users: stub_users()}}
  end

  describe "new" do
    fn conn, _context ->
      get(conn, theme_path(conn, :new))
    end
    |> behaves_like([:authenticated, :admin], "GET /themes/new")

    test "renders the new template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      conn = get(conn, theme_path(conn, :new))

      assert html_response(conn, 200) =~ "Theme"
    end
  end

  describe "create" do
    fn conn, context ->
      post(conn, theme_path(conn, :create, %{"theme" => context.valid_params}))
    end
    |> behaves_like([:authenticated, :sponsor], "POST /themes/create")

    test "creates a theme", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.admin)
      conn = post(conn, theme_path(conn, :create, %{"theme" => valid_params}))
      assert conn |> Phoenix.Controller.get_flash(:info) == "Theme created successfully."

      assert redirected_to(conn, 302) ==
               theme_path(conn, :show, CodeFund.Schema.Theme |> CodeFund.Repo.one())
    end

    test "returns an error on invalid params for a theme", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(conn, theme_path(conn, :create, %{"theme" => valid_params |> Map.delete("name")}))

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.form.errors == [name: ["can't be blank"]]
      assert conn.private.phoenix_template == "new.html"
    end
  end
end
