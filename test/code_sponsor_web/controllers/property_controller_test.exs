defmodule CodeSponsorWeb.PropertyControllerTest do
  use CodeSponsorWeb.ConnCase

  alias CodeSponsor.Properties

  @create_attrs %{description: "some description", name: "some name", property_type: 42, url: "some url"}
  @update_attrs %{description: "some updated description", name: "some updated name", property_type: 43, url: "some updated url"}
  @invalid_attrs %{description: nil, name: nil, property_type: nil, url: nil}

  def fixture(:property) do
    {:ok, property} = Properties.create_property(@create_attrs)
    property
  end

  describe "index" do
    test "lists all properties", %{conn: conn} do
      conn = get conn, property_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Properties"
    end
  end

  describe "new property" do
    test "renders form", %{conn: conn} do
      conn = get conn, property_path(conn, :new)
      assert html_response(conn, 200) =~ "New Property"
    end
  end

  describe "create property" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, property_path(conn, :create), property: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == property_path(conn, :show, id)

      conn = get conn, property_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Property"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, property_path(conn, :create), property: @invalid_attrs
      assert html_response(conn, 200) =~ "New Property"
    end
  end

  describe "edit property" do
    setup [:create_property]

    test "renders form for editing chosen property", %{conn: conn, property: property} do
      conn = get conn, property_path(conn, :edit, property)
      assert html_response(conn, 200) =~ "Edit Property"
    end
  end

  describe "update property" do
    setup [:create_property]

    test "redirects when data is valid", %{conn: conn, property: property} do
      conn = put conn, property_path(conn, :update, property), property: @update_attrs
      assert redirected_to(conn) == property_path(conn, :show, property)

      conn = get conn, property_path(conn, :show, property)
      assert html_response(conn, 200) =~ "some updated description"
    end

    test "renders errors when data is invalid", %{conn: conn, property: property} do
      conn = put conn, property_path(conn, :update, property), property: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Property"
    end
  end

  describe "delete property" do
    setup [:create_property]

    test "deletes chosen property", %{conn: conn, property: property} do
      conn = delete conn, property_path(conn, :delete, property)
      assert redirected_to(conn) == property_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, property_path(conn, :show, property)
      end
    end
  end

  defp create_property(_) do
    property = fixture(:property)
    {:ok, property: property}
  end
end
