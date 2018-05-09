defmodule CodeFundWeb.ThemeControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    template = insert(:template)
    valid_params = string_params_with_assocs(:theme, template: template)

    {:ok, %{valid_params: valid_params, users: stub_users(), template: template}}
  end

  describe "new" do
    fn conn, _context ->
      get(conn, theme_path(conn, :new))
    end
    |> behaves_like([:authenticated, :admin], "GET /themes/new")

    test "renders the new theme", %{conn: conn, users: users, template: template} do
      conn = assign(conn, :current_user, users.admin)
      conn = get(conn, theme_path(conn, :new))

      assert conn.assigns.template_choices == [{template.name, template.id}]

      assert html_response(conn, 200) =~ "Theme"
    end
  end

  describe "create" do
    fn conn, context ->
      post(conn, theme_path(conn, :create, %{"params" => %{"theme" => context.valid_params}}))
    end
    |> behaves_like([:authenticated, :sponsor], "POST /themes/create")

    test "creates a theme", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.admin)
      conn = post(conn, theme_path(conn, :create, %{"params" => %{"theme" => valid_params}}))
      assert conn |> Phoenix.Controller.get_flash(:info) == "Theme created successfully."

      assert redirected_to(conn, 302) ==
               theme_path(conn, :show, CodeFund.Schema.Theme |> CodeFund.Repo.one())
    end

    test "returns an error on invalid params for a theme", %{
      conn: conn,
      users: users,
      valid_params: valid_params,
      template: template
    } do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(
          conn,
          theme_path(conn, :create, %{
            "params" => %{"theme" => valid_params |> Map.put("name", nil)}
          })
        )

      assert conn.assigns.template_choices == [{template.name, template.id}]

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [name: {"can't be blank", [validation: :required]}]
      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "edit" do
    fn conn, _context ->
      get(conn, theme_path(conn, :edit, insert(:theme)))
    end
    |> behaves_like([:authenticated, :admin], "GET /themes/edit")

    test "renders the edit theme", %{conn: conn, users: users, template: template} do
      conn = assign(conn, :current_user, users.admin)
      theme = insert(:theme)
      conn = get(conn, theme_path(conn, :edit, theme))

      assert conn.assigns.template_choices == [{template.name, template.id}]
      assert html_response(conn, 200) =~ "Template"
      assert html_response(conn, 200) =~ theme.name
    end
  end

  describe "update" do
    fn conn, _context ->
      patch(conn, theme_path(conn, :update, insert(:theme), %{"name" => "name"}))
    end
    |> behaves_like([:authenticated, :admin], "PATCH /themes/update")

    test "updates a theme", %{conn: conn, users: users, valid_params: valid_params} do
      theme = insert(:theme)
      conn = assign(conn, :current_user, users.admin)

      conn =
        patch(
          conn,
          theme_path(conn, :update, theme, %{
            "params" => %{"theme" => valid_params |> Map.put("name", "New Name")}
          })
        )

      assert redirected_to(conn, 302) == theme_path(conn, :show, theme)
      assert CodeFund.Themes.get_theme!(theme.id).name == "New Name"
    end

    test "returns an error on invalid params for a theme", %{
      conn: conn,
      users: users,
      valid_params: valid_params,
      template: template
    } do
      conn = assign(conn, :current_user, users.admin)

      conn =
        patch(
          conn,
          theme_path(conn, :update, insert(:theme), %{
            "params" => %{"theme" => valid_params |> Map.put("name", nil)}
          })
        )

      assert conn.assigns.template_choices == [{template.name, template.id}]

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [name: {"can't be blank", [validation: :required]}]
      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "delete" do
    fn conn, _context ->
      delete(conn, theme_path(conn, :delete, insert(:theme)))
    end
    |> behaves_like([:authenticated, :sponsor], "DELETE /themes/:id")

    test "deletes the theme and redirects to index", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      theme = insert(:theme)
      conn = delete(conn, theme_path(conn, :delete, theme))

      assert conn |> Phoenix.Controller.get_flash(:info) == "Theme deleted successfully."
      assert redirected_to(conn, 302) == theme_path(conn, :index)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.Themes.get_theme!(theme.id).name == nil
                   end
    end
  end
end
