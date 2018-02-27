defmodule CodeSponsorWeb.CampaignController do
  use CodeSponsorWeb, :controller

  alias CodeSponsor.Campaigns
  alias CodeSponsor.Campaigns.Campaign

  def index(conn, _params) do
    campaigns = Campaigns.list_campaigns()
    render(conn, "index.html", campaigns: campaigns)
  end

  def new(conn, _params) do
    changeset = Campaigns.change_campaign(%Campaign{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"campaign" => campaign_params}) do
    case Campaigns.create_campaign(campaign_params) do
      {:ok, campaign} ->
        conn
        |> put_flash(:info, "Campaign created successfully.")
        |> redirect(to: campaign_path(conn, :show, campaign))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)
    render(conn, "show.html", campaign: campaign)
  end

  def edit(conn, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)
    changeset = Campaigns.change_campaign(campaign)
    render(conn, "edit.html", campaign: campaign, changeset: changeset)
  end

  def update(conn, %{"id" => id, "campaign" => campaign_params}) do
    campaign = Campaigns.get_campaign!(id)

    case Campaigns.update_campaign(campaign, campaign_params) do
      {:ok, campaign} ->
        conn
        |> put_flash(:info, "Campaign updated successfully.")
        |> redirect(to: campaign_path(conn, :show, campaign))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", campaign: campaign, changeset: changeset)
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
