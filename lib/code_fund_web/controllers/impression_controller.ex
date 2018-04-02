defmodule CodeFundWeb.ImpressionController do
  use CodeFundWeb, :controller

  alias CodeFund.Impressions
  alias CodeFund.Schema.Impression

  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin"])

  def index(conn, params) do
    case Impressions.paginate_impressions(params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        report(:error)

        conn
        |> put_flash(:error, "There was an error rendering Impressions. #{inspect(error)}")
        |> redirect(to: impression_path(conn, :index))
    end
  end

  def new(conn, _params) do
    changeset = Impressions.change_impression(%Impression{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"impression" => impression_params}) do
    case Impressions.create_impression(impression_params) do
      {:ok, impression} ->
        conn
        |> put_flash(:info, "Impression created successfully.")
        |> redirect(to: impression_path(conn, :show, impression))

      {:error, %Ecto.Changeset{} = changeset} ->
        report(:warn, "Changeset Error")
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    impression = Impressions.get_impression!(id)
    render(conn, "show.html", impression: impression)
  end

  def edit(conn, %{"id" => id}) do
    impression = Impressions.get_impression!(id)
    changeset = Impressions.change_impression(impression)
    render(conn, "edit.html", impression: impression, changeset: changeset)
  end

  def update(conn, %{"id" => id, "impression" => impression_params}) do
    impression = Impressions.get_impression!(id)

    case Impressions.update_impression(impression, impression_params) do
      {:ok, impression} ->
        conn
        |> put_flash(:info, "Impression updated successfully.")
        |> redirect(to: impression_path(conn, :show, impression))

      {:error, %Ecto.Changeset{} = changeset} ->
        report(:warn, "Changeset Error")
        render(conn, "edit.html", impression: impression, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    impression = Impressions.get_impression!(id)
    {:ok, _impression} = Impressions.delete_impression(impression)

    conn
    |> put_flash(:info, "Impression deleted successfully.")
    |> redirect(to: impression_path(conn, :index))
  end
end
