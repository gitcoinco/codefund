defmodule AdService.Query.ForDisplayTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  setup do
    creative = insert(:creative)

    insert(:audience, %{
      programming_languages: ["Ruby", "C"],
      topic_categories: ["Programming"],
      excluded_countries: ["US"]
    })

    insert(:audience, %{
      programming_languages: ["Ruby", "C"],
      topic_categories: ["Development"],
      excluded_countries: ["US"]
    })

    audience =
      insert(:audience, %{
        programming_languages: ["Ruby", "C"],
        topic_categories: ["Programming"],
        excluded_countries: ["CN"]
      })

    insert(:audience, %{
      programming_languages: ["Java", "Rust"],
      topic_categories: ["Development"],
      excluded_countries: ["IN"]
    })

    campaign =
      insert(
        :campaign,
        status: 2,
        bid_amount: Decimal.new("1.00"),
        budget_daily_amount: Decimal.new(1),
        budget_monthly_amount: Decimal.new(1),
        budget_total_amount: Decimal.new(1),
        creative: creative,
        audience: audience
      )

    insert(
      :campaign,
      status: 2,
      bid_amount: Decimal.new(0),
      budget_daily_amount: Decimal.new(0),
      budget_monthly_amount: Decimal.new(0),
      budget_total_amount: Decimal.new(0),
      creative: creative,
      audience: audience
    )

    insert(
      :campaign,
      status: 2,
      bid_amount: Decimal.new(1),
      budget_daily_amount: Decimal.new(1),
      budget_monthly_amount: Decimal.new(1),
      budget_total_amount: Decimal.new(1),
      creative: creative,
      audience: insert(:audience, %{programming_languages: ["Java", "Rust"]})
    )

    insert(
      :campaign,
      status: 1,
      bid_amount: Decimal.new(1),
      budget_daily_amount: Decimal.new(1),
      budget_monthly_amount: Decimal.new(1),
      budget_total_amount: Decimal.new(1),
      creative: creative,
      audience: audience
    )

    {:ok, %{creative: creative, campaign: campaign}}
  end

  describe "build/1" do
    test "it returns advertisements by property filters", %{
      campaign: campaign,
      creative: creative
    } do
      advertisement =
        AdService.Query.ForDisplay.build(
          programming_languages: ["C"],
          topic_categories: ["Programming"],
          client_country: "US"
        )
        |> CodeFund.Repo.one()

      assert advertisement == %AdService.Advertisement{
               body: creative.body,
               campaign_id: campaign.id,
               image_url: creative.image_url,
               headline: creative.headline,
               bid_amount: campaign.bid_amount
             }
    end

    test "get_by_property_filters excludes indicated countries" do
      refute AdService.Query.ForDisplay.build(
               programming_languages: ["C"],
               topic_categories: ["Programming"],
               client_country: "CN"
             )
             |> CodeFund.Repo.one()
    end
  end
end
