defmodule CodeFundWeb.SponsorshipController do
  @module "Sponsorship"
  use CodeFundWeb, :controller
  use Framework.Controller
  use Framework.Controller.Stub.Definitions, [@module, [:index, :show, :delete]]

  alias CodeFund.Schema.{Sponsorship, User}
  alias Framework.Phoenix.Form.Helpers, as: FormHelpers
  alias CodeFund.{Campaigns, Creatives, Properties}

  plug(CodeFundWeb.Plugs.RequireAnyRole, roles: ["admin", "sponsor"])

  defstub new(@module) do
    before_hook(&sponsorship/2)
  end

  defstub create(@module) do
    inject_params(&CodeFundWeb.Hooks.Shared.join_to_user_id/2)
    |> before_hook(&sponsorship/2)
  end

  defstub edit(@module) do
    before_hook(&sponsorship/2)
  end

  defstub update(@module) do
    before_hook(&sponsorship/2)
  end

  defp sponsorship(conn, %{"id" => id}) do
    CodeFund.Sponsorships.get_sponsorship!(id) |> base(conn)
  end

  defp sponsorship(conn, _params) do
    %Sponsorship{} |> base(conn)
  end

  defp base(sponsorship, conn) do
    campaign_choices =
      Campaigns.by_user(conn.assigns.current_user) |> FormHelpers.repo_objects_to_options()

    creative_choices =
      Creatives.by_user(conn.assigns.current_user) |> FormHelpers.repo_objects_to_options()

    property_choices = Properties.list_properties() |> FormHelpers.repo_objects_to_options()

    fields = [
      campaign_id: [type: :select, label: "Campaign", opts: [choices: campaign_choices]],
      property_id: [type: :select, label: "Property", opts: [choices: property_choices]],
      creative_id: [type: :select, label: "Creative", opts: [choices: creative_choices]],
      bid_amount: [type: :currency_input, label: "CPC"],
      redirect_url: [type: :text_input, label: "URL", opts: [placeholder: "https://"]]
    ]

    override_revenue_rate =
      case conn.assigns.current_user.roles |> CodeFund.Users.has_role?(["admin"]) do
        true ->
          [
            override_revenue_rate: [
              type: :currency_input,
              label: "Override Revenue Rate",
              opts: [value: set_override_revenue_rate_default(sponsorship)]
            ]
          ]

        false ->
          [
            override_revenue_rate: [
              type: :hidden_input,
              label: " ",
              opts: [value: set_override_revenue_rate_default(sponsorship)]
            ]
          ]
      end

    [fields: Enum.concat(fields, override_revenue_rate)]
  end

  defp set_override_revenue_rate_default(%Sponsorship{
         override_revenue_rate: override_revenue_rate
       })
       when not is_nil(override_revenue_rate),
       do: override_revenue_rate

  defp set_override_revenue_rate_default(%Sponsorship{user: %User{revenue_rate: revenue_rate}})
       when not is_nil(revenue_rate),
       do: revenue_rate

  defp set_override_revenue_rate_default(_), do: "0.50"
end
