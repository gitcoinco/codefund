defmodule CodeFundWeb.TemplateControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    valid_params = string_params_with_assocs(:template)

    {:ok, %{valid_params: valid_params, users: stub_users()}}
  end

  describe "new" do
    fn conn, _context ->
      get(conn, theme_path(conn, :new))
    end
    |> behaves_like([:authenticated, :admin], "GET /templates/new")

    test "renders the new theme", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      conn = get(conn, template_path(conn, :new))

      assert html_response(conn, 200) =~ "Template"
    end
  end

  describe "create" do
    fn conn, context ->
      post(conn, template_path(conn, :create, %{"template" => context.valid_params}))
    end
    |> behaves_like([:authenticated, :sponsor], "POST /templates/create")

    test "creates a template", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.admin)
      conn = post(conn, template_path(conn, :create, %{"template" => valid_params}))
      assert conn |> Phoenix.Controller.get_flash(:info) == "Template created successfully."

      assert redirected_to(conn, 302) ==
               template_path(conn, :show, CodeFund.Schema.Template |> CodeFund.Repo.one())
    end

    test "returns an error on invalid params for a template", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(
          conn,
          template_path(conn, :create, %{"template" => valid_params |> Map.delete("name")})
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.form.errors == [name: ["can't be blank"]]
      assert conn.private.phoenix_template == "new.html"
    end
  end
end
