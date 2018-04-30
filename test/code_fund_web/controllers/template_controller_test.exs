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
      post(
        conn,
        template_path(conn, :create, %{"params" => %{"template" => context.valid_params}})
      )
    end
    |> behaves_like([:authenticated, :sponsor], "POST /templates/create")

    test "creates a template", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(conn, template_path(conn, :create, %{"params" => %{"template" => valid_params}}))

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
          template_path(conn, :create, %{
            "params" => %{"template" => valid_params |> Map.put("name", nil)}
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [name: {"can't be blank", [validation: :required]}]
      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "edit" do
    fn conn, _context ->
      get(conn, template_path(conn, :edit, insert(:template)))
    end
    |> behaves_like([:authenticated, :admin], "GET /templates/edit")

    test "renders the edit template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      template = insert(:template)
      conn = get(conn, template_path(conn, :edit, template))

      assert html_response(conn, 200) =~ "Template"
      assert html_response(conn, 200) =~ template.name
    end
  end

  describe "update" do
    fn conn, _context ->
      patch(conn, template_path(conn, :update, insert(:template), %{"name" => "name"}))
    end
    |> behaves_like([:authenticated, :admin], "PATCH /templates/update")

    test "updates a template", %{conn: conn, users: users, valid_params: valid_params} do
      template = insert(:template)
      conn = assign(conn, :current_user, users.admin)

      conn =
        patch(
          conn,
          template_path(conn, :update, template, %{
            "params" => %{"template" => valid_params |> Map.put("name", "New Name")}
          })
        )

      assert redirected_to(conn, 302) == template_path(conn, :show, template)
      assert CodeFund.Templates.get_template!(template.id).name == "New Name"
    end

    test "returns an error on invalid params for a template", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.admin)

      conn =
        patch(
          conn,
          template_path(conn, :update, insert(:template), %{
            "params" => %{"template" => valid_params |> Map.put("name", nil)}
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [name: {"can't be blank", [validation: :required]}]
      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "delete" do
    fn conn, _context ->
      delete(conn, template_path(conn, :delete, insert(:template)))
    end
    |> behaves_like([:authenticated, :sponsor], "DELETE /templates/:id")

    test "deletes the template and redirects to index", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      template = insert(:template)
      conn = delete(conn, template_path(conn, :delete, template))

      assert conn |> Phoenix.Controller.get_flash(:info) == "Template deleted successfully."
      assert redirected_to(conn, 302) == template_path(conn, :index)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.Templates.get_template!(template.id).name == nil
                   end
    end
  end
end
