defmodule CodeSponsorWeb.PropertyController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.Properties
  alias CodeSponsor.Properties.Property
  alias CodeSponsorWeb.PropertyType

  def index(conn, params) do
    current_user = conn.assigns.current_user
    case Properties.paginate_properties(current_user, params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Properties. #{inspect(error)}")
        |> redirect(to: property_path(conn, :index))
    end
  end

  def new(conn, _params) do
    form = create_form(PropertyType, %Property{})
    render(conn, "new.html", form: form)
  end

  def create(conn, %{"property" => property_params}) do
    current_user = conn.assigns.current_user
    PropertyType
      |> create_form(%Property{}, property_params, user: current_user)
      |> insert_form_data
      |> case do
        {:ok, property} ->
          conn
          |> put_flash(:info, "Property created successfully.")
          |> redirect(to: property_path(conn, :show, property))
        {:error, form} ->
          render(conn, "new.html", form: form)
      end
  end

  def show(conn, %{"id" => id}) do
    property = Properties.get_property!(id)
    render(conn, "show.html", property: property)
  end

  def edit(conn, %{"id" => id}) do
    property = Properties.get_property!(id)
    form = create_form(PropertyType, property)
    render(conn, "edit.html", form: form, property: property)
  end

  def update(conn, %{"id" => id, "property" => property_params}) do
    current_user = conn.assigns.current_user
    property = Properties.get_property!(id)

    PropertyType
      |> create_form(property, property_params, user: current_user)
      |> update_form_data
      |> case do
        {:ok, property} ->
          conn
          |> put_flash(:info, "Property updated successfully.")
          |> redirect(to: property_path(conn, :show, property))
        {:error, form} ->
          render(conn, "edit.html", property: property, form: form)
      end
  end

  def delete(conn, %{"id" => id}) do
    property = Properties.get_property!(id)
    {:ok, _property} = Properties.delete_property(property)

    conn
    |> put_flash(:info, "Property deleted successfully.")
    |> redirect(to: property_path(conn, :index))
  end
end
