defmodule CodeSponsorWeb.CreativeController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.Creatives
  alias CodeSponsor.Schema.Creative
  alias CodeSponsorWeb.CreativeType

  plug CodeSponsorWeb.Plugs.RequireAnyRole, [roles: ["admin", "sponsor"]]

  def index(conn, params) do
    case Creatives.paginate_creatives(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering creatives. #{inspect(error)}")
        |> redirect(to: creative_path(conn, :index))
    end
  end

  def new(conn, _params) do
    form = create_form(CreativeType, %Creative{})
    render(conn, "new.html", form: form)
  end

  def create(conn, %{"creative" => creative_params}) do
    current_user = conn.assigns.current_user

    CreativeType
      |> create_form(%Creative{}, creative_params, user: current_user)
      |> insert_form_data
      |> case do
        {:ok, creative} ->
          conn
          |> put_flash(:info, "Creative created successfully.")
          |> redirect(to: creative_path(conn, :show, creative))
        {:error, form} ->
          render(conn, "new.html", form: form)
      end
  end

  def show(conn, %{"id" => id}) do
    creative = Creatives.get_creative!(id)
    render(conn, "show.html", creative: creative)
  end

  def edit(conn, %{"id" => id}) do
    creative = Creatives.get_creative!(id)
    form = create_form(CreativeType, creative)
    render(conn, "edit.html", form: form, creative: creative)
  end

  def update(conn, %{"id" => id, "creative" => creative_params}) do
    current_user = conn.assigns.current_user
    creative = Creatives.get_creative!(id)

    CreativeType
      |> create_form(creative, creative_params, user: current_user)
      |> update_form_data
      |> case do
        {:ok, creative} ->
          conn
          |> put_flash(:info, "Creative updated successfully.")
          |> redirect(to: creative_path(conn, :show, creative))
        {:error, form} ->
          render(conn, "edit.html", creative: creative, form: form)
      end
  end

  def delete(conn, %{"id" => id}) do
    creative = Creatives.get_creative!(id)
    {:ok, _creative} = Creatives.delete_creative(creative)

    conn
    |> put_flash(:info, "Creative deleted successfully.")
    |> redirect(to: creative_path(conn, :index))
  end
end
