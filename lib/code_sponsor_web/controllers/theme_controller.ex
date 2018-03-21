defmodule CodeSponsorWeb.ThemeController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.Creatives
  alias CodeSponsor.Creatives.Theme
  alias CodeSponsorWeb.ThemeType

  plug CodeSponsorWeb.Plugs.RequireAnyRole, %{roles: ["admin"], to: "/dashboard"}

  def index(conn, params) do
    case Creatives.paginate_themes(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering themes. #{inspect(error)}")
        |> redirect(to: theme_path(conn, :index))
    end
  end

  def new(conn, _params) do
    form = create_form(ThemeType, %Theme{})
    render(conn, "new.html", form: form)
  end

  def create(conn, %{"theme" => theme_params}) do
    ThemeType
      |> create_form(%Theme{}, theme_params)
      |> insert_form_data
      |> case do
        {:ok, theme} ->
          conn
          |> put_flash(:info, "Theme created successfully.")
          |> redirect(to: theme_path(conn, :show, theme))
        {:error, form} ->
          render(conn, "new.html", form: form)
      end
  end

  def show(conn, %{"id" => id}) do
    theme = Creatives.get_theme!(id)
    render(conn, "show.html", theme: theme)
  end

  def edit(conn, %{"id" => id}) do
    theme = Creatives.get_theme!(id)
    form = create_form(ThemeType, theme)
    render(conn, "edit.html", form: form, theme: theme)
  end

  def update(conn, %{"id" => id, "theme" => theme_params}) do
    theme = Creatives.get_theme!(id)

    ThemeType
      |> create_form(theme, theme_params)
      |> update_form_data
      |> case do
        {:ok, theme} ->
          conn
          |> put_flash(:info, "Theme updated successfully.")
          |> redirect(to: theme_path(conn, :show, theme))
        {:error, form} ->
          render(conn, "edit.html", theme: theme, form: form)
      end
  end

  def delete(conn, %{"id" => id}) do
    theme = Creatives.get_theme!(id)
    {:ok, _theme} = Creatives.delete_theme(theme)

    conn
    |> put_flash(:info, "Theme deleted successfully.")
    |> redirect(to: theme_path(conn, :index))
  end
end
