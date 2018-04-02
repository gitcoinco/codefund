defmodule CodeFundWeb.ClickController do
  use CodeFundWeb, :controller

  alias CodeFund.Clicks
  alias CodeFund.Schema.Click

  def index(conn, _params) do
    clicks = Clicks.list_clicks()
    render(conn, "index.html", clicks: clicks)
  end

  def new(conn, _params) do
    changeset = Clicks.change_click(%Click{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"click" => click_params}) do
    case Clicks.create_click(click_params) do
      {:ok, click} ->
        conn
        |> put_flash(:info, "Click created successfully.")
        |> redirect(to: click_path(conn, :show, click))

      {:error, %Ecto.Changeset{} = changeset} ->
        report(:warn, "Changeset Error")
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    click = Clicks.get_click!(id)
    render(conn, "show.html", click: click)
  end

  def edit(conn, %{"id" => id}) do
    click = Clicks.get_click!(id)
    changeset = Clicks.change_click(click)
    render(conn, "edit.html", click: click, changeset: changeset)
  end

  def update(conn, %{"id" => id, "click" => click_params}) do
    click = Clicks.get_click!(id)

    case Clicks.update_click(click, click_params) do
      {:ok, click} ->
        conn
        |> put_flash(:info, "Click updated successfully.")
        |> redirect(to: click_path(conn, :show, click))

      {:error, %Ecto.Changeset{} = changeset} ->
        report(:warn, "Changeset Error")
        render(conn, "edit.html", click: click, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    click = Clicks.get_click!(id)
    {:ok, _click} = Clicks.delete_click(click)

    conn
    |> put_flash(:info, "Click deleted successfully.")
    |> redirect(to: click_path(conn, :index))
  end
end
