defmodule CodeFundWeb.CampaignController do
  use CodeFundWeb, :controller
  use Framework.Controller
  alias CodeFund.{Campaigns, Users}
  alias CodeFund.Schema.{Campaign, User}
  alias Framework.Phoenix.Form.Helpers, as: FormHelpers
  use Framework.Controller.Stub.Definitions, [:index, :show, :delete]
  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  defconfig do
    [schema: "Campaign"]
  end

  defstub new do
    before_hook(&new_assigns/2)
    |> error(&new_assigns/2)
  end

  defstub edit do
    before_hook(&edit_assigns/2)
  end

  defstub update do
    before_hook(&edit_assigns/2)
  end

  defstub create do
    before_hook(&new_assigns/2)
    |> inject_params(&CodeFundWeb.Hooks.Shared.join_to_user_id/2)
    |> error(&new_assigns/2)
  end

  def generate_fraud_check_url(conn, %{"id" => id}) do
    campaign = Campaigns.get_campaign!(id)

    Exq.enqueue(Exq, "cs_high", CodeFundWeb.CreateFraudTrackingLinkWorker, [campaign.id])

    conn
    |> put_flash(:info, "Fraud Check URL is being generated")
    |> redirect(to: campaign_path(conn, :show, campaign))
  end

  defp new_assigns(conn, _params) do
    controller_assigns(conn.assigns.current_user, nil)
  end

  defp edit_assigns(_conn, %{"id" => campaign_id}) do
    campaign = Campaigns.get_campaign!(campaign_id)
    user = CodeFund.Users.get_user!(campaign.user_id)
    controller_assigns(user, campaign)
  end

  defp controller_assigns(user, campaign) do
    [
      audiences:
        CodeFund.Audiences.get_by_user(user)
        |> CodeFund.Repo.all()
        |> FormHelpers.repo_objects_to_options(),
      creatives:
        CodeFund.Creatives.by_user(user)
        |> FormHelpers.repo_objects_to_options(),
      revenue_rate: set_override_revenue_rate_default(campaign),
      revenue_rate_field_type: revenue_rate_field_type(user),
      revenue_rate_field_label: revenue_rate_field_label(user)
    ]
  end

  defp revenue_rate_field_label(user) do
    case Users.has_role?(user.roles, ["admin"]) do
      true -> "Override Revenue Rate"
      false -> ""
    end
  end

  defp revenue_rate_field_type(user) do
    case Users.has_role?(user.roles, ["admin"]) do
      true -> :currency_input
      false -> :hidden_input
    end
  end

  defp set_override_revenue_rate_default(%Campaign{
         override_revenue_rate: override_revenue_rate
       })
       when not is_nil(override_revenue_rate),
       do: override_revenue_rate

  defp set_override_revenue_rate_default(%Campaign{user: %User{revenue_rate: revenue_rate}})
       when not is_nil(revenue_rate),
       do: revenue_rate

  defp set_override_revenue_rate_default(_), do: "0.50"
end
