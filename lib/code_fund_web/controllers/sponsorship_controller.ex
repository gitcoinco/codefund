defmodule CodeFundWeb.SponsorshipController do
  use CodeFundWeb, :controller
  import Ecto.Query

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
    current_user = conn.assigns.current_user

    form =
      create_form(SponsorshipType, %Sponsorship{})
      |> form_treatment(current_user)

    render(conn, "new.html", form: form)
  end

  def create(conn, %{"sponsorship" => sponsorship_params}) do
    current_user = conn.assigns.current_user

    SponsorshipType
    |> create_form(%Sponsorship{}, sponsorship_params, user: current_user)
    |> form_treatment(current_user)
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
    current_user = conn.assigns.current_user
    sponsorship = Sponsorships.get_sponsorship!(id)

    form =
      create_form(SponsorshipType, sponsorship)
      |> form_treatment(current_user)

    render(conn, "edit.html", form: form, sponsorship: sponsorship)
  end

  def update(conn, %{"id" => id, "sponsorship" => sponsorship_params}) do
    current_user = conn.assigns.current_user
    sponsorship = Sponsorships.get_sponsorship!(id)

    SponsorshipType
    |> create_form(sponsorship, sponsorship_params, user: current_user)
    |> form_treatment(current_user)
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

  defp new_select_field(type, id_key, current_user_id) do
    %Formex.Field{
      custom_value: nil,
      data: [
        choices:
          from(o in Module.concat([CodeFund, Schema, type]), where: o.user_id == ^current_user_id)
          |> CodeFund.Repo.all()
          |> Enum.map(fn object -> {object.name, object.id} end)
      ],
      label: "#{type}",
      name: id_key,
      phoenix_opts: [class: ""],
      required: true,
      struct_name: id_key,
      type: :select,
      validation: [:required]
    }
  end

  defp form_treatment(form, current_user) do
    form_items =
      form.items
      |> List.insert_at(0, new_select_field(Campaign, :campaign_id, current_user.id))
      |> List.insert_at(2, new_select_field(Creative, :creative_id, current_user.id))

    Map.put(form, :items, form_items)
  end
end
