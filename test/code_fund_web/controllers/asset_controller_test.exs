defmodule CodeFundWeb.AssetControllerTest do
  use CodeFundWeb.ConnCase

  setup do
    # JBEAN TODO: Figure out how to pass upload plug struct through controller tests
    valid_params = string_params_with_assocs(:asset, user: nil) |> Map.delete("image")

    {:ok, %{valid_params: valid_params, users: stub_users()}}
  end

  describe "index" do
    fn conn, _context ->
      get(conn, asset_path(conn, :index))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /Assets")

    test "renders the index as a sponsor", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.sponsor)
      asset = insert(:asset, user: users.sponsor)
      insert(:asset)
      asset = CodeFund.Assets.get_asset!(asset.id)
      conn = get(conn, asset_path(conn, :index))

      assert conn.assigns.assets |> CodeFund.Repo.preload(:user) == [asset]
      assert html_response(conn, 200) =~ "Assets"
    end

    test "renders the index as an admin", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      asset = insert(:asset)
      asset = CodeFund.Assets.get_asset!(asset.id)
      conn = get(conn, asset_path(conn, :index))

      assert conn.assigns.assets |> CodeFund.Repo.preload(:user) == [asset]
      assert html_response(conn, 200) =~ "Assets"
    end
  end

  describe "new" do
    fn conn, _context ->
      get(conn, asset_path(conn, :new))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /assets/new")

    test "renders the new template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      conn = get(conn, asset_path(conn, :new))

      assert html_response(conn, 200) =~ "Asset"
    end
  end

  describe "create" do
    fn conn, context ->
      post(
        conn,
        asset_path(conn, :create, %{"params" => %{"asset" => context.valid_params}})
      )
    end
    |> behaves_like([:authenticated, :sponsor], "POST /assets/create")

    test "creates a asset", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.sponsor)

      conn = post(conn, asset_path(conn, :create, %{"params" => %{"asset" => valid_params}}))

      assert conn |> Phoenix.Controller.get_flash(:info) == "Asset created successfully."

      assert redirected_to(conn, 302) ==
               asset_path(conn, :show, CodeFund.Schema.Asset |> CodeFund.Repo.one())
    end

    test "returns an error on invalid params for a asset", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.sponsor)

      conn =
        post(
          conn,
          asset_path(conn, :create, %{
            "params" => %{"asset" => valid_params |> Map.put("name", nil)}
          })
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.changeset.errors == [name: {"can't be blank", [validation: :required]}]
      assert conn.private.phoenix_template == "form_container.html"
    end
  end

  describe "show" do
    fn conn, _context ->
      get(conn, asset_path(conn, :show, insert(:asset)))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /assets/:id")

    test "renders the show template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      asset = insert(:asset)
      conn = get(conn, asset_path(conn, :show, asset))

      assert html_response(conn, 200) =~ "Asset"
      assert html_response(conn, 200) =~ asset.name
    end
  end

  describe "edit" do
    fn conn, _context ->
      get(conn, asset_path(conn, :edit, insert(:asset)))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /assets/edit")

    test "renders the edit template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      asset = insert(:asset)
      conn = get(conn, asset_path(conn, :edit, asset))

      assert html_response(conn, 200) =~ "Asset"
      assert html_response(conn, 200) =~ asset.name
    end
  end

  describe "update" do
    fn conn, _context ->
      patch(conn, asset_path(conn, :update, insert(:asset), %{"name" => "name"}))
    end
    |> behaves_like([:authenticated, :sponsor], "PATCH /assets/update")

    test "updates a asset", %{conn: conn, users: users, valid_params: valid_params} do
      asset = insert(:asset)
      conn = assign(conn, :current_user, users.admin)

      conn =
        patch(
          conn,
          asset_path(conn, :update, asset, %{
            "params" => %{"asset" => valid_params |> Map.put("name", "New Name")}
          })
        )

      assert redirected_to(conn, 302) == asset_path(conn, :show, asset)
      assert CodeFund.Assets.get_asset!(asset.id).name == "New Name"
    end

    test "returns an error on invalid params for a asset", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.sponsor)

      conn =
        patch(
          conn,
          asset_path(conn, :update, insert(:asset), %{
            "params" => %{"asset" => valid_params |> Map.put("name", nil)}
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
      delete(conn, asset_path(conn, :delete, insert(:asset)))
    end
    |> behaves_like([:authenticated, :sponsor], "DELETE /assets/:id")

    test "deletes the asset and redirects to index", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      asset = insert(:asset)
      conn = delete(conn, asset_path(conn, :delete, asset))

      assert conn |> Phoenix.Controller.get_flash(:info) == "Asset deleted successfully."
      assert redirected_to(conn, 302) == asset_path(conn, :index)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.Assets.get_asset!(asset.id).name == nil
                   end
    end
  end
end
