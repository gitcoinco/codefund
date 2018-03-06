defmodule CodeSponsorWeb.CampaignController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.Campaigns
  alias CodeSponsor.Campaigns.Campaign
  alias CodeSponsorWeb.CampaignType

  def index(conn, params) do
    current_user = conn.assigns.current_user
    case Campaigns.paginate_campaigns(current_user, params) do
      {:ok, assigns} ->
        render(conn, "index.html", assigns)
      error ->
        conn
        |> put_flash(:error, "There was an error rendering Campaigns. #{inspect(error)}")
        |> redirect(to: campaign_path(conn, :index))
    end
  end

  def new(conn, _params) do
    form = create_form(CampaignType, %Campaign{})
    render(conn, "new.html", form: form)
  end

  def create(conn, %{"campaign" => campaign_params}) do
    current_user = conn.assigns.current_user

    CampaignType
      |> create_form(%Campaign{}, campaign_params, user: current_user)
      |> insert_form_data
      |> case do
        {:ok, campaign} ->
          conn
          |> put_flash(:info, "Campaign created successfully.")
          |> redirect(to: campaign_path(conn, :index))
        {:error, form} ->
          render(conn, "new.html", form: form)
      end
  end

  def show(conn, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)
    render(conn, "show.html", campaign: campaign)
  end

  def edit(conn, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)
    form = create_form(CampaignType, campaign)
    render(conn, "edit.html", form: form, campaign: campaign)
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do
    current_user = conn.assigns.current_user
    campaign = Campaigns.get_campaign!(id)

    CampaignType
      |> create_form(campaign, campaign_params, user: current_user)
      |> update_form_data
      |> case do
        {:ok, campaign} ->
          conn
          |> put_flash(:info, "Campaign updated successfully.")
          |> redirect(to: campaign_path(conn, :show, campaign))
        {:error, form} ->
          render(conn, "edit.html", campaign: campaign, form: form)
      end
  end

  def delete(conn, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)
    {:ok, _campaign} = Campaigns.delete_campaign(campaign)

    conn
    |> put_flash(:info, "Campaign deleted successfully.")
    |> redirect(to: campaign_path(conn, :index))
  end
end
