defmodule CodeFundWeb.User.AudienceControllerTest do
  use CodeFundWeb.ConnCase
  import Ecto.Query
  import CodeFund.Factory

  setup do
    users = stub_users()

    audience = insert(:audience)

    authed_conn = assign(build_conn(), :current_user, users.admin)

    {:ok,
     %{
       authed_conn: authed_conn,
       users: users,
       audience: audience
     }}
  end

  def shared_assigns_test(conn, user_id, action \\ :create) do
    assert conn.private.controller_config.schema == "Audience"
    assert conn.private.controller_config.nested == ["User"]
    assert conn.assigns.action == action

    assert conn.assigns.associations == [user_id]
  end

  describe "index" do
    fn conn, context ->
      get(conn, user_audience_path(conn, :index, context.users.sponsor))
    end
    |> behaves_like([:authenticated, :sponsor], "GET /users/user_id/audiences")

    test "renders the index as a sponsor", %{conn: conn, users: users} do
      conn = assign(conn, :current_user, users.sponsor)
      audience = insert(:audience, user: users.sponsor)
      insert(:audience, user: users.admin)
      insert(:audience)
      audience = CodeFund.Audiences.get_audience!(audience.id)
      conn = get(conn, user_audience_path(conn, :index, users.sponsor))

      assert conn.assigns.audiences |> CodeFund.Repo.preload(:user) == [audience]
      assert html_response(conn, 200) =~ "Audiences"
    end

    test "renders the index as an admin", %{conn: conn, users: users, audience: audience} do
      conn = assign(conn, :current_user, users.admin)
      audience_2 = insert(:audience)

      audience_1 = CodeFund.Audiences.get_audience!(audience.id)
      audience_2 = CodeFund.Audiences.get_audience!(audience_2.id)
      conn = get(conn, user_audience_path(conn, :index, users.sponsor))

      assert conn.assigns.audiences |> CodeFund.Repo.preload(:user) == [audience_2, audience_1]
      assert html_response(conn, 200) =~ "Audiences"
    end
  end

  describe "show" do
    fn conn, context ->
      get(conn, user_audience_path(conn, :show, context.users.sponsor, context.audience))
    end
    |> behaves_like(
      [:authenticated, :owned_unless_admin, :sponsor],
      "GET /users/user_id/audiences/id"
    )

    test "it displays the show page", %{
      authed_conn: authed_conn,
      users: users,
      audience: audience
    } do
      authed_conn =
        get(
          authed_conn,
          user_audience_path(authed_conn, :show, users.developer, audience)
        )

      assert html_response(authed_conn, 200) =~ "Audiences"
    end
  end

  describe "new" do
    fn conn, context ->
      get(conn, user_audience_path(conn, :new, context.users.sponsor))
    end
    |> behaves_like(
      [:authenticated, :owned_unless_admin, :sponsor],
      "GET /users/user_id/audiences/new"
    )

    test "shows the audience new page for a developer account", %{
      users: users,
      authed_conn: authed_conn
    } do
      authed_conn =
        get(
          authed_conn,
          user_audience_path(authed_conn, :new, users.sponsor)
        )

      assert html_response(authed_conn, 200) =~ "New Audience"

      shared_assigns_test(authed_conn, users.sponsor.id)
    end
  end

  describe "create" do
    fn conn, context ->
      post(
        conn,
        user_audience_path(conn, :create, context.users.sponsor, %{
          "params" => %{
            "audience" => %{
              "name" => "test audience",
              "programming_languages" => ["Ruby"],
              "topic_categories" => ["Programming"]
            }
          }
        })
      )
    end
    |> behaves_like(
      [:authenticated, :owned_unless_admin, :sponsor],
      "POST /users/user_id/audiences/"
    )

    test "successfully creates a audience", %{
      authed_conn: authed_conn
    } do
      authed_conn =
        post(
          authed_conn,
          user_audience_path(authed_conn, :create, authed_conn.assigns.current_user, %{
            "params" => %{
              "audience" => %{
                "name" => "test audience",
                "programming_languages" => ["Ruby"],
                "topic_categories" => ["Programming"]
              }
            }
          })
        )

      audience = from(d in CodeFund.Schema.Audience) |> CodeFund.Repo.all() |> List.last()
      assert audience.name == "test audience"
      assert audience.programming_languages == ["Ruby"]
      assert audience.user_id == authed_conn.assigns.current_user.id

      assert redirected_to(authed_conn, 302) ==
               user_audience_path(authed_conn, :show, authed_conn.assigns.current_user, audience)

      shared_assigns_test(authed_conn, authed_conn.assigns.current_user.id)
    end

    test "returns an error on invalid params", %{
      authed_conn: authed_conn
    } do
      authed_conn =
        post(
          authed_conn,
          user_audience_path(authed_conn, :create, authed_conn.assigns.current_user, %{
            "params" => %{
              "audience" => %{
                "programming_languages" => ["Ruby"],
                "topic_categories" => ["Programming"]
              }
            }
          })
        )

      assert html_response(authed_conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert authed_conn.assigns.changeset.errors == [
               name: {"can't be blank", [validation: :required]}
             ]

      assert authed_conn.private.phoenix_template == "form_container.html"
      shared_assigns_test(authed_conn, authed_conn.assigns.current_user.id)
    end
  end

  describe "edit" do
    fn conn, context ->
      get(conn, user_audience_path(conn, :edit, context.users.sponsor, insert(:audience)))
    end
    |> behaves_like(
      [:authenticated, :owned_unless_admin, :sponsor],
      "GET /users/user_id/audiences/id/edit"
    )

    test "renders the edit template", %{
      authed_conn: authed_conn,
      audience: audience
    } do
      authed_conn =
        get(
          authed_conn,
          user_audience_path(authed_conn, :edit, authed_conn.assigns.current_user, audience)
        )

      assert html_response(authed_conn, 200) =~ "Audience"
      assert html_response(authed_conn, 200) =~ audience.name
    end
  end

  describe "delete" do
    fn conn, context ->
      delete(conn, user_audience_path(conn, :delete, context.users.sponsor, insert(:audience)))
    end
    |> behaves_like(
      [:authenticated, :owned_unless_admin, :sponsor],
      "DELETE /users/user_id/audiences/:id"
    )

    test "deletes the audience and redirects to index", %{
      authed_conn: authed_conn,
      audience: audience
    } do
      authed_conn =
        delete(
          authed_conn,
          user_audience_path(authed_conn, :delete, authed_conn.assigns.current_user, audience)
        )

      assert authed_conn |> Phoenix.Controller.get_flash(:info) ==
               "Audience deleted successfully."

      assert redirected_to(authed_conn, 302) ==
               user_audience_path(authed_conn, :index, authed_conn.assigns.current_user)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.Audiences.get_audience!(audience.id).name == nil
                   end
    end
  end

  describe "update" do
    fn conn, context ->
      patch(
        conn,
        user_audience_path(conn, :update, context.users.sponsor, insert(:audience), %{
          "params" => %{
            "audience" => %{
              "name" => "test audience",
              "programming_languages" => ["Ruby"]
            }
          }
        })
      )
    end
    |> behaves_like(
      [:authenticated, :owned_unless_admin, :sponsor],
      "PATCH /users/user_id/audiences/"
    )

    test "successfully updates a audience", %{
      authed_conn: authed_conn
    } do
      audience = insert(:audience, name: "old name", user: authed_conn.assigns.current_user)

      authed_conn =
        patch(
          authed_conn,
          user_audience_path(authed_conn, :update, authed_conn.assigns.current_user, audience, %{
            "params" => %{
              "audience" => %{
                "name" => "new name",
                "programming_languages" => ["Ruby"]
              }
            }
          })
        )

      audience = CodeFund.Audiences.get_audience!(audience.id)
      assert audience.name == "new name"
      assert audience.programming_languages == ["Ruby"]
      assert audience.user_id == authed_conn.assigns.current_user.id

      assert redirected_to(authed_conn, 302) ==
               user_audience_path(authed_conn, :show, authed_conn.assigns.current_user, audience)

      shared_assigns_test(authed_conn, authed_conn.assigns.current_user.id, :update)
    end

    test "returns an error on invalid params", %{
      authed_conn: authed_conn
    } do
      authed_conn =
        patch(
          authed_conn,
          user_audience_path(
            authed_conn,
            :update,
            authed_conn.assigns.current_user,
            insert(:audience, user: authed_conn.assigns.current_user),
            %{
              "params" => %{
                "audience" => %{
                  "name" => "",
                  "programming_languages" => ["Ruby"]
                }
              }
            }
          )
        )

      assert html_response(authed_conn, 422) =~
               "Oops, something went wrong! Please check the errors below."

      assert authed_conn.assigns.changeset.errors == [
               name: {"can't be blank", [validation: :required]}
             ]

      assert authed_conn.private.phoenix_template == "form_container.html"
      shared_assigns_test(authed_conn, authed_conn.assigns.current_user.id, :update)
    end
  end
end
