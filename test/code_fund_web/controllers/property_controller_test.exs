defmodule CodeFundWeb.PropertyControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    users = stub_users()

    valid_params = string_params_with_assocs(:property, user: nil)

    {:ok, %{valid_params: valid_params, users: users}}
  end

  describe "index" do
    fn conn, _context ->
      get(conn, property_path(conn, :index))
    end
    |> behaves_like([:authenticated], "GET /Property")

    test "renders the index as a developer", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.developer)
      property = insert(:property, user: users.developer)
      insert(:property)
      property = CodeFund.Properties.get_property!(property.id)
      conn = get(conn, property_path(conn, :index))

      assert conn.assigns.properties |> CodeFund.Repo.preload(:user) == [property]
      assert html_response(conn, 200) =~ "Property"
    end

    test "renders the index as an admin", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      property = insert(:property)
      property = CodeFund.Properties.get_property!(property.id)
      conn = get(conn, property_path(conn, :index))

      assert conn.assigns.properties |> CodeFund.Repo.preload(:user) == [property]
      assert html_response(conn, 200) =~ "Property"
    end
  end

  describe "new" do
    fn conn, _context ->
      get(conn, property_path(conn, :new))
    end
    |> behaves_like([:authenticated], "GET /properties/new")

    test "renders the new template as a developer", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.developer)
      conn = get(conn, property_path(conn, :new))

      assert conn.assigns.fields |> Keyword.keys() == [
               :name,
               :description,
               :url,
               :estimated_monthly_page_views,
               :estimated_monthly_visitors,
               :language,
               :programming_languages,
               :topic_categories
             ]

      assert html_response(conn, 200) =~ "Property"
    end

    test "renders the new template as a admin", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      conn = get(conn, property_path(conn, :new))

      assert conn.assigns.fields |> Keyword.keys() == [
               :name,
               :description,
               :url,
               :estimated_monthly_page_views,
               :estimated_monthly_visitors,
               :language,
               :programming_languages,
               :topic_categories,
               :status,
               :alexa_site_rank,
               :screenshot_url
             ]

      assert html_response(conn, 200) =~ "Property"
    end
  end

  describe "create" do
    fn conn, context ->
      post(
        conn,
        property_path(conn, :create, %{"params" => %{"property" => context.valid_params}})
      )
    end
    |> behaves_like([:authenticated], "POST /properties/create")

    test "creates a property", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(conn, property_path(conn, :create, %{"params" => %{"property" => valid_params}}))

      assert conn |> Phoenix.Controller.get_flash(:info) == "Property created successfully."

      assert redirected_to(conn, 302) ==
               property_path(conn, :show, CodeFund.Schema.Property |> CodeFund.Repo.one())
    end

    test "returns an error on invalid params for a property", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.admin)

      conn =
        post(
          conn,
          property_path(conn, :create, %{
            "params" => %{"property" => valid_params |> Map.put("name", nil)}
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.fields |> Keyword.keys() == [
               :name,
               :description,
               :url,
               :estimated_monthly_page_views,
               :estimated_monthly_visitors,
               :language,
               :programming_languages,
               :topic_categories,
               :status,
               :alexa_site_rank,
               :screenshot_url
             ]

      assert conn.assigns.changeset.errors == [name: {"can't be blank", [validation: :required]}]
      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "show" do
    fn conn, _context ->
      get(conn, property_path(conn, :show, insert(:property)))
    end
    |> behaves_like([:authenticated], "GET /properties/:id")

    test "renders the show template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      property = insert(:property)
      conn = get(conn, property_path(conn, :show, property))

      assert html_response(conn, 200) =~ "Property"
      assert html_response(conn, 200) =~ property.name
    end
  end

  describe "edit" do
    fn conn, _context ->
      get(conn, property_path(conn, :edit, insert(:property)))
    end
    |> behaves_like([:authenticated], "GET /properties/edit")

    test "renders the edit template", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      property = insert(:property)
      conn = get(conn, property_path(conn, :edit, property))

      assert html_response(conn, 200) =~ "Property"
      assert html_response(conn, 200) =~ property.name

      assert conn.assigns.fields |> Keyword.keys() == [
               :name,
               :description,
               :url,
               :estimated_monthly_page_views,
               :estimated_monthly_visitors,
               :language,
               :programming_languages,
               :topic_categories,
               :status,
               :alexa_site_rank,
               :screenshot_url
             ]
    end
  end

  describe "update" do
    fn conn, _context ->
      patch(
        conn,
        property_path(conn, :update, insert(:property), %{"bid_amount" => "bid_amount"})
      )
    end
    |> behaves_like([:authenticated], "PATCH /properties/update")

    test "updates a property", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)

      property = insert(:property)

      conn =
        patch(
          conn,
          property_path(conn, :update, property, %{
            "params" => %{
              "property" => %{
                name: "New Name",
                programming_languages: ["Ruby"],
                topic_categories: ["Frontend Frameworks & Tools"]
              }
            }
          })
        )

      assert redirected_to(conn, 302) == property_path(conn, :show, property)

      assert CodeFund.Properties.get_property!(property.id).name == "New Name"
    end

    test "returns an error on invalid params for a property", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.admin)

      property = insert(:property)

      conn =
        patch(
          conn,
          property_path(conn, :update, property, %{
            "params" => %{"property" => valid_params |> Map.put("name", nil)}
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.fields |> Keyword.keys() == [
               :name,
               :description,
               :url,
               :estimated_monthly_page_views,
               :estimated_monthly_visitors,
               :language,
               :programming_languages,
               :topic_categories,
               :status,
               :alexa_site_rank,
               :screenshot_url
             ]

      assert conn.assigns.changeset.errors == [name: {"can't be blank", [validation: :required]}]
      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "delete" do
    fn conn, _context ->
      delete(conn, property_path(conn, :delete, insert(:property)))
    end
    |> behaves_like([:authenticated], "DELETE /properties/:id")

    test "deletes the property and redirects to index", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      property = insert(:property)
      conn = delete(conn, property_path(conn, :delete, property))

      assert conn |> Phoenix.Controller.get_flash(:info) == "Property deleted successfully."
      assert redirected_to(conn, 302) == property_path(conn, :index)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.Properties.get_property!(property.id).bid_amount == nil
                   end
    end
  end
end
