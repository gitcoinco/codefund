defmodule CodeFundWeb.CampaignController do
  use CodeFundWeb, :controller
  use Framework.Controller
  alias CodeFund.Campaigns
  alias CodeFund.Schema.Campaign
  alias Framework.Phoenix.Form.Helpers, as: FormHelpers
  use Framework.Controller.Stub.Definitions, [:index, :show, :delete]

  plug(
    CodeFundWeb.Plugs.RequireAnyRole,
    [roles: ["admin", "sponsor"]] when action in [:edit, :update, :delete, :index, :show]
  )

  plug(
    CodeFundWeb.Plugs.RequireAnyRole,
    [roles: ["admin"]] when action in [:create, :new, :duplicate]
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
    |> error(&new_assigns/2)
  end

  def duplicate(conn, %{"campaign_id" => campaign_id}) do
    {:ok, %Campaign{id: duplicated_campaign_id}} =
      campaign_id
      |> Campaigns.get_campaign!()
      |> Campaigns.duplicate_campaign()

    conn
    |> put_flash(:info, "Campaign duplicated successfully.")
    |> redirect(external: campaign_path(conn, :edit, duplicated_campaign_id))
  end

  defp new_assigns(conn, params) do
    user =
      case params["params"]["campaign"]["user_id"] do
        nil -> conn.assigns.current_user
        user_id -> CodeFund.Users.get_user!(user_id)
      end

    form_fields(true, user)
  end

  defp edit_assigns(conn, %{"id" => campaign_id}) do
    campaign = Campaigns.get_campaign!(campaign_id)

    conn.assigns.current_user.roles
    |> CodeFund.Users.has_role?(["admin"])
    |> form_fields(campaign.user)
  end

  defp form_fields(is_admin, user) do
    [audiences: audiences, creatives: creatives] = audiences_and_creatives_by_user(user)

    fields = [
      user_id: [
        type: :select,
        label: "Advertiser",
        opts: [
          disabled: !is_admin,
          prompt: "Select a User",
          choices:
            CodeFund.Users.get_by_role("sponsor")
            |> FormHelpers.repo_objects_to_options([:first_name, :last_name], " "),
          data: [
            target: "campaign-form.userId",
            action: "change->campaign-form#creativesForUser"
          ]
        ]
      ],
      name: [type: :text_input, label: "Name", opts: [disabled: !is_admin]],
      active_dates: [
        type: :text_input,
        label: "Date Range",
        opts: [
          disabled: !is_admin,
          data: [target: "date-range.datePicker"]
        ]
      ],
      status: [
        type: :select,
        label: "Status",
        opts: [choices: CodeFund.Campaigns.statuses()]
      ],
      audience_id: [type: :select, label: "Audience", opts: [choices: audiences]],
      creative_id: [
        type: :select,
        label: "Creative",
        opts: [
          prompt: "Select a Creative",
          choices: creatives,
          data: [target: "campaign-form.creatives"]
        ]
      ],
      redirect_url: [type: :text_input, label: "Redirect URL", opts: [placeholder: "https://"]],
      budget_daily_amount: [
        type: :currency_input,
        label: "Daily Max Spend",
        opts: [step: "0.01"]
      ],
      total_spend: [
        type: :currency_input,
        label: "Total Spend",
        opts: [
          step: "0.01",
          data: [
            target: "campaign-form.totalBudget",
            action: "change->campaign-form#calculateImpressions"
          ]
        ]
      ],
      ecpm: [
        type: :currency_input,
        label: "eCPM",
        opts: [
          step: "0.01",
          min: "0",
          step: "0.01",
          data: [
            target: "campaign-form.ecpm",
            action: "change->campaign-form#calculateImpressions"
          ]
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
      us_hours_only: [
        type: :checkbox,
        label: "US Hours Only",
        opts: [
          hint: "If checked, this campaign will only run between 5AM - 5PM PST (San Francisco)"
        ]
      ],
      weekdays_only: [
        type: :checkbox,
        label: "Weekdays Only",
        opts: [
          hint: "If checked, this campaign will only run on weekdays in the user's local timezone"
        ]
      ],
      start_date: [
        type: :hidden_input,
        label: "",
        opts: [
          data: [target: "date-range.startDate"]
        ]
      ],
      end_date: [
        type: :hidden_input,
        label: "",
        opts: [
          data: [target: "date-range.endDate"]
        ]
      ]
    ]

    admin_only_fields = [
      :audience_id,
      :ecpm,
      :included_countries,
      :total_spend,
      :us_hours_only,
      :user_id,
      :weekdays_only
    ]

    fields =
      if is_admin do
        fields
      else
        fields = Enum.reject(fields, fn {key, _} -> Enum.member?(admin_only_fields, key) end)
      end

    [fields: fields]
  end

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
