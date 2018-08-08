defmodule CodeFundWeb.CampaignController do
  use CodeFundWeb, :controller
  use Framework.Controller
  alias CodeFund.Campaigns
  alias Framework.Phoenix.Form.Helpers, as: FormHelpers
  use Framework.Controller.Stub.Definitions, [:index, :show, :delete]

  plug(
    CodeFundWeb.Plugs.RequireAnyRole,
    [roles: ["admin", "sponsor"]] when action in [:edit, :update, :delete, :index, :show]
  )

  plug(
    CodeFundWeb.Plugs.RequireAnyRole,
    [roles: ["admin"]] when action in [:create, :new]
  )

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

  defp new_assigns(conn, _params) do
    form_fields(true, conn.assigns.current_user)
  end

  defp edit_assigns(conn, %{"id" => campaign_id}) do
    campaign = Campaigns.get_campaign!(campaign_id)

    conn.assigns.current_user.roles
    |> CodeFund.Users.has_role?(["admin"])
    |> form_fields(campaign.user)
  end

  defp form_fields(true, user) do
    [audiences: audiences, creatives: creatives] = audiences_and_creatives_by_user(user)

    [
      fields: [
        name: [type: :text_input, label: "Name"],
        redirect_url: [type: :text_input, label: "Redirect URL", opts: [placeholder: "https://"]],
        status: [
          type: :select,
          label: "Status",
          opts: [choices: CodeFund.Campaigns.statuses()]
        ],
        active_dates: [
          type: :text_input,
          label: "Date Range",
          opts: [
            "data-target": "date-range.datePicker"
          ]
        ],
        creative_id: [
          type: :select,
          label: "Creative",
          opts: [choices: creatives, "data-target": "campaign-form.creatives"]
        ],
        audience_id: [type: :select, label: "Audience", opts: [choices: audiences]],
        user_id: [
          type: :select,
          label: "User",
          opts: [
            choices:
              CodeFund.Users.get_by_role("sponsor")
              |> FormHelpers.repo_objects_to_options([:first_name, :last_name], " "),
            "data-target": "campaign-form.userId",
            "data-action": "change->campaign-form#creativesForUser"
          ]
        ],
        ecpm: [
          type: :currency_input,
          label: "eCPM",
          opts: [
            step: "0.01",
            min: "0",
            "data-target": "campaign-form.ecpm",
            "data-action": "change->campaign-form#calculateImpressions",
            step: "0.01"
          ]
        ],
        included_countries: [
          type: :multiple_select,
          label: "Included Countries",
          opts: [
            data: [
              target: "campaign-form.includedCountries",
              action: "change->campaign-form#generateEstimates",
              key: "included_countries"
            ],
            class: "form-control campaign-form selectize",
            choices: Framework.Geolocation.Countries.list(),
            hint: ~s"""
            <div>
              <span class="click-option" data-action='click->campaign-form#selectRecommendedCountries'>Recommended</span> |
              <span class="click-option" data-action='click->campaign-form#selectPopularCountries'>Popular</span> |
              <span class="click-option" data-action='click->campaign-form#selectAllCountries'>All</span> |
              <span class="click-option" data-action='click->campaign-form#selectNoCountries'>None</span>
            </div>
            """
          ]
        ],
        budget_daily_amount: [
          type: :currency_input,
          label: "Daily Max Spend",
          opts: [step: "0.01"]
        ],
        total_spend: [
          type: :currency_input,
          label: "Total Spend",
          opts: [
            "data-target": "campaign-form.totalBudget",
            "data-action": "change->campaign-form#calculateImpressions",
            step: "0.01"
          ]
        ],
        impression_count: [
          type: :number_input,
          label: "Estimated Impressions",
          opts: ["data-target": "campaign-form.estimatedImpressions"]
        ],
        start_date: [
          type: :hidden_input,
          label: "",
          opts: ["data-target": "date-range.startDate"]
        ],
        end_date: [
          type: :hidden_input,
          label: "",
          opts: ["data-target": "date-range.endDate"]
        ]
      ]
    ]
  end

  defp form_fields(false, user),
    do: [fields: form_fields(true, user)[:fields] |> Keyword.drop([:audience_id, :total_spend])]

  defp audiences_and_creatives_by_user(user) do
    [
      audiences:
        CodeFund.Audiences.list_audiences()
        |> FormHelpers.repo_objects_to_options(),
      creatives:
        CodeFund.Creatives.by_user_id(user.id)
        |> FormHelpers.repo_objects_to_options()
    ]
  end
end
