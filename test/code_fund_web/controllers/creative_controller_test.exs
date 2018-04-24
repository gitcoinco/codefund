defmodule CodeFundWeb.CreativeControllerTest do
  use CodeFundWeb.ConnCase
  import SharedExample.ControllerTests
  import CodeFund.Factory

  setup do
    valid_params = string_params_with_assocs(:creative, user: nil)

    {:ok, %{valid_params: valid_params, users: stub_users()}}
  end

  describe "index" do
    fn conn, _context ->
      get(conn, creative_path(conn, :index))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /Creatives")

    test "renders the index as a sponsor", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.sponsor)
      creative = insert(:creative, user: users.sponsor)
      insert(:creative)
      creative = CodeFund.Creatives.get_creative!(creative.id)
      conn = get(conn, creative_path(conn, :index))

      assert conn.assigns.creatives |> CodeFund.Repo.preload(:user) == [creative]
      assert html_response(conn, 200) =~ "Creatives"
    end

    test "renders the index as an admin", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.admin)
      creative = insert(:creative)
      creative = CodeFund.Creatives.get_creative!(creative.id)
      conn = get(conn, creative_path(conn, :index))

      assert conn.assigns.creatives |> CodeFund.Repo.preload(:user) == [creative]
      assert html_response(conn, 200) =~ "Creatives"
    end
  end

  describe "new" do
    fn conn, _context ->
      get(conn, creative_path(conn, :new))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /creatives/new")

    test "renders the new template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      conn = get(conn, creative_path(conn, :new))

      assert html_response(conn, 200) =~ "Creative"
    end
  end

  describe "create" do
    fn conn, context ->
      post(conn, creative_path(conn, :create, %{"creative" => context.valid_params}))
    end
    |> behaves_like([:authenticated, :sponsor], "POST /creatives/create")

    test "creates a creative", %{conn: conn, users: users, valid_params: valid_params} do
      conn = assign(conn, :current_user, users.sponsor)
      conn = post(conn, creative_path(conn, :create, %{"creative" => valid_params}))
      assert conn |> Phoenix.Controller.get_flash(:info) == "Creative created successfully."

      assert redirected_to(conn, 302) ==
               creative_path(conn, :show, CodeFund.Schema.Creative |> CodeFund.Repo.one())
    end

    test "returns an error on invalid params for a creative", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.sponsor)

      conn =
        post(
          conn,
          creative_path(conn, :create, %{"creative" => valid_params |> Map.delete("name")})
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.form.errors == [name: ["can't be blank"]]
      assert conn.private.phoenix_template == "new.html"
    end
  end

  describe "show" do
    fn conn, _context ->
      get(conn, creative_path(conn, :show, insert(:creative)))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /creatives/:id")

    test "renders the show template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      creative = insert(:creative)
      conn = get(conn, creative_path(conn, :show, creative))

      assert html_response(conn, 200) =~ "Creative"
      assert html_response(conn, 200) =~ creative.name
    end
  end

  describe "edit" do
    fn conn, _context ->
      get(conn, creative_path(conn, :edit, insert(:creative)))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /creatives/edit")

    test "renders the edit template", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      creative = insert(:creative)
      conn = get(conn, creative_path(conn, :edit, creative))

      assert html_response(conn, 200) =~ "Creative"
      assert html_response(conn, 200) =~ creative.name
    end
  end

  describe "update" do
    fn conn, _context ->
      patch(conn, creative_path(conn, :update, insert(:creative), %{"name" => "name"}))
    end
    |> behaves_like([:authenticated, :sponsor], "PATCH /creatives/update")

    test "updates a creative", %{conn: conn, users: users, valid_params: valid_params} do
      creative = insert(:creative)
      conn = assign(conn, :current_user, users.admin)

      conn =
        patch(
          conn,
          creative_path(conn, :update, creative, %{
            "creative" => valid_params |> Map.put("name", "New Name")
          })
        )

      assert redirected_to(conn, 302) == creative_path(conn, :show, creative)
      assert CodeFund.Creatives.get_creative!(creative.id).name == "New Name"
    end

    test "returns an error on invalid params for a creative", %{
      conn: conn,
      users: users,
      valid_params: valid_params
    } do
      conn = assign(conn, :current_user, users.sponsor)

      conn =
        post(
          conn,
          creative_path(conn, :create, %{"creative" => valid_params |> Map.delete("name")})
        )

      assert html_response(conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert conn.assigns.form.errors == [name: ["can't be blank"]]
      assert conn.private.phoenix_template == "new.html"
    end
  end

  describe "delete" do
    fn conn, _context ->
      delete(conn, creative_path(conn, :delete, insert(:creative)))
    end
    |> behaves_like([:authenticated, :sponsor], "DELETE /creatives/:id")

    test "deletes the creative and redirects to index", %{conn: conn} do
      conn = assign(conn, :current_user, insert(:user))
      creative = insert(:creative)
      conn = delete(conn, creative_path(conn, :delete, creative))

      assert conn |> Phoenix.Controller.get_flash(:info) == "Creative deleted successfully."
      assert redirected_to(conn, 302) == creative_path(conn, :index)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.Creatives.get_creative!(creative.id).name == nil
                   end
    end
  end
end
