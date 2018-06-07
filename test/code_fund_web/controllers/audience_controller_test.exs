defmodule CodeFundWeb.AudienceControllerTest do
  use CodeFundWeb.ConnCase
  import Ecto.Query
  import CodeFund.Factory

  setup do
    users = stub_users()
    audience = insert(:audience, name: "Some Audience")

    authed_conn = assign(build_conn(), :current_user, users.admin)

    {:ok,
     %{
       authed_conn: authed_conn,
       users: users,
       audience: audience
     }}
  end

  def shared_assigns_test(conn) do
    assert conn.private.controller_config.schema == "Audience"
  end

  describe "index" do
    fn conn, _context ->
      get(conn, audience_path(conn, :index))
    end
    |> behaves_like([:authenticated, :admin], "GET /audiences")

    test "renders the index", %{authed_conn: conn, audience: audience} do
      audience_2 = insert(:audience)

      audience_1 = CodeFund.Audiences.get_audience!(audience.id)
      audience_2 = CodeFund.Audiences.get_audience!(audience_2.id)
      conn = get(conn, audience_path(conn, :index))

      assert conn.assigns.audiences == [audience_1, audience_2]
      assert html_response(conn, 200) =~ "Audiences"
    end
  end

  describe "show" do
    fn conn, _context ->
      get(conn, audience_path(conn, :show, insert(:audience)))
    end
    |> behaves_like(
      [:authenticated, :admin],
      "GET /audiences/id"
    )

    test "it displays the show page", %{
      authed_conn: authed_conn,
      audience: audience
    } do
      authed_conn =
        get(
          authed_conn,
          audience_path(authed_conn, :show, audience)
        )

      assert html_response(authed_conn, 200) =~ "Audiences"
    end
  end

  describe "new" do
    fn conn, _context ->
      get(conn, audience_path(conn, :new))
    end
    |> behaves_like(
      [:authenticated, :admin],
      "GET /audiences/new"
    )

    test "shows the audience new page", %{
      authed_conn: authed_conn
    } do
      authed_conn =
        get(
          authed_conn,
          audience_path(authed_conn, :new)
        )

      assert html_response(authed_conn, 200) =~ "New Audience"

      shared_assigns_test(authed_conn)
    end
  end

  describe "create" do
    fn conn, _context ->
      post(
        conn,
        audience_path(conn, :create, %{
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
      [:authenticated, :admin],
      "POST /audiences/"
    )

    test "successfully creates a audience", %{
      authed_conn: authed_conn
    } do
      authed_conn =
        post(
          authed_conn,
          audience_path(authed_conn, :create, %{
            "params" => %{
              "audience" => %{
                "name" => "test audience",
                "programming_languages" => ["Ruby"]
              }
            }
          })
        )

      audience = from(d in CodeFund.Schema.Audience) |> CodeFund.Repo.all() |> List.last()
      assert audience.name == "test audience"
      assert audience.programming_languages == ["Ruby"]

      assert redirected_to(authed_conn, 302) == audience_path(authed_conn, :show, audience)

      shared_assigns_test(authed_conn)
    end

    test "returns an error on invalid params", %{
      authed_conn: authed_conn
    } do
      authed_conn =
        post(
          authed_conn,
          audience_path(authed_conn, :create, %{
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
      shared_assigns_test(authed_conn)
    end
  end

  describe "edit" do
    fn conn, _context ->
      get(conn, audience_path(conn, :edit, insert(:audience)))
    end
    |> behaves_like(
      [:authenticated, :admin],
      "GET /audiences/id/edit"
    )

    test "renders the edit template", %{
      authed_conn: authed_conn,
      audience: audience
    } do
      authed_conn =
        get(
          authed_conn,
          audience_path(authed_conn, :edit, audience)
        )

      assert html_response(authed_conn, 200) =~ "Audience"
      assert html_response(authed_conn, 200) =~ audience.name
    end
  end

  describe "delete" do
    fn conn, _context ->
      delete(conn, audience_path(conn, :delete, insert(:audience)))
    end
    |> behaves_like(
      [:authenticated, :admin],
      "DELETE /audiences/:id"
    )

    test "deletes the audience and redirects to index", %{
      authed_conn: authed_conn,
      audience: audience
    } do
      authed_conn =
        delete(
          authed_conn,
          audience_path(authed_conn, :delete, audience)
        )

      assert authed_conn |> Phoenix.Controller.get_flash(:info) ==
               "Audience deleted successfully."

      assert redirected_to(authed_conn, 302) == audience_path(authed_conn, :index)

      assert_raise Ecto.NoResultsError,
                   ~r/expected at least one result but got none in query/,
                   fn ->
                     CodeFund.Audiences.get_audience!(audience.id).name == nil
                   end
    end
  end

  describe "update" do
    fn conn, _context ->
      patch(
        conn,
        audience_path(conn, :update, insert(:audience), %{
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
      [:authenticated, :admin],
      "PATCH /audiences/"
    )

    test "successfully updates a audience", %{
      authed_conn: authed_conn
    } do
      audience = insert(:audience, name: "old name")

      authed_conn =
        patch(
          authed_conn,
          audience_path(authed_conn, :update, audience, %{
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

      assert redirected_to(authed_conn, 302) == audience_path(authed_conn, :show, audience)

      shared_assigns_test(authed_conn)
    end

    test "returns an error on invalid params", %{
      authed_conn: authed_conn
    } do
      authed_conn =
        patch(
          authed_conn,
          audience_path(authed_conn, :update, insert(:audience), %{
            "params" => %{
              "audience" => %{
                "name" => "",
                "programming_languages" => ["Ruby"]
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
      shared_assigns_test(authed_conn)
    end
  end
end
