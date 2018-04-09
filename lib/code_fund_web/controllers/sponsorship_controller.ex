defmodule CodeFundWeb.SponsorshipController do
  use CodeFundWeb, :controller

  alias CodeFund.Sponsorships
  alias CodeFund.Schema.Sponsorship
  alias CodeFundWeb.SponsorshipType

  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  def index(conn, params) do
    current_user = conn.assigns.current_user

    case Sponsorships.paginate_sponsorships(current_user, params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)

      error ->
        report(:error)

        conn
        |> put_flash(:error, "There was an error rendering sponsorships. #{inspect(error)}")
        |> redirect(to: sponsorship_path(conn, :index))
    end
  end

  def new(conn, _params) do
    form = create_form(SponsorshipType, %Sponsorship{})
    render(conn, "new.html", form: form)
  end

  def create(conn, %{"sponsorship" => sponsorship_params}) do
    current_user = conn.assigns.current_user

    SponsorshipType
    |> create_form(%Sponsorship{}, sponsorship_params, user: current_user)
    |> insert_form_data
    |> case do
      {:ok, sponsorship} ->
        conn
        |> put_flash(:info, "Sponsorship created successfully.")
        |> redirect(to: sponsorship_path(conn, :show, sponsorship))

      {:error, form} ->
        report(:warn, "Changeset Error")
        render(conn, "new.html", form: form)
    end
  end

  def show(conn, %{"id" => id}) do
    sponsorship = Sponsorships.get_sponsorship!(id)
    render(conn, "show.html", sponsorship: sponsorship)
  end

  def edit(conn, %{"id" => id}) do
    sponsorship = Sponsorships.get_sponsorship!(id)
    form = create_form(SponsorshipType, sponsorship)
    render(conn, "edit.html", form: form, sponsorship: sponsorship)
  end

  def update(conn, %{"id" => id, "sponsorship" => sponsorship_params}) do
    current_user = conn.assigns.current_user
    sponsorship = Sponsorships.get_sponsorship!(id)

    SponsorshipType
    |> create_form(sponsorship, sponsorship_params, user: current_user)
    |> update_form_data
    |> case do
      {:ok, sponsorship} ->
        conn
        |> put_flash(:info, "Sponsorship updated successfully.")
        |> redirect(to: sponsorship_path(conn, :show, sponsorship))

      {:error, form} ->
        report(:warn, "Changeset Error")
        render(conn, "edit.html", sponsorship: sponsorship, form: form)
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
