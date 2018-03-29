defmodule CodeFundWeb.PropertyController do
  use CodeFundWeb, :controller

  alias CodeFund.Properties
  alias CodeFund.Schema.Property
  alias CodeFund.Sponsorships
  alias CodeFundWeb.PropertyType

  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "developer"])

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
    current_user = conn.assigns.current_user
    form = create_form(PropertyType, %Property{}, %{}, user: current_user)
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

    sponsorship =
      case property.sponsorship_id do
        nil -> nil
        _ -> Sponsorships.get_sponsorship!(property.sponsorship_id)
      end

    render(conn, "show.html", property: property, sponsorship: sponsorship)
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
