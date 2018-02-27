defmodule CodeSponsorWeb.SponsorshipController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.Sponsorships
  alias CodeSponsor.Sponsorships.Sponsorship

  def index(conn, _params) do
    sponsorships = Sponsorships.list_sponsorships()
    render(conn, "index.html", sponsorships: sponsorships)
  end

  def new(conn, _params) do
    changeset = Sponsorships.change_sponsorship(%Sponsorship{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"sponsorship" => sponsorship_params}) do
    case Sponsorships.create_sponsorship(sponsorship_params) do
      {:ok, sponsorship} ->
        conn
        |> put_flash(:info, "Sponsorship created successfully.")
        |> redirect(to: sponsorship_path(conn, :show, sponsorship))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    sponsorship = Sponsorships.get_sponsorship!(id)
    render(conn, "show.html", sponsorship: sponsorship)
  end

  def edit(conn, %{"id" => id}) do
    sponsorship = Sponsorships.get_sponsorship!(id)
    changeset = Sponsorships.change_sponsorship(sponsorship)
    render(conn, "edit.html", sponsorship: sponsorship, changeset: changeset)
  end

  def update(conn, %{"id" => id, "sponsorship" => sponsorship_params}) do
    sponsorship = Sponsorships.get_sponsorship!(id)

    case Sponsorships.update_sponsorship(sponsorship, sponsorship_params) do
      {:ok, sponsorship} ->
        conn
        |> put_flash(:info, "Sponsorship updated successfully.")
        |> redirect(to: sponsorship_path(conn, :show, sponsorship))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", sponsorship: sponsorship, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    sponsorship = Sponsorships.get_sponsorship!(id)
    {:ok, _sponsorship} = Sponsorships.delete_sponsorship(sponsorship)

    conn
    |> put_flash(:info, "Sponsorship deleted successfully.")
    |> redirect(to: sponsorship_path(conn, :index))
  end
end
