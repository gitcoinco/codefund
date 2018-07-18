defmodule AdService.Query.ForDisplayTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  setup do
    creative = insert(:creative, headline: "winning advertisement")

    insert(:audience, %{
      programming_languages: ["Ruby", "C"],
      topic_categories: ["Programming"]
    })

    insert(:audience, %{
      programming_languages: ["Ruby", "C"],
      topic_categories: ["Development"]
    })

    audience =
      insert(:audience, %{
        programming_languages: ["Ruby", "C"],
        topic_categories: ["Programming"]
      })

    insert(:audience, %{
      programming_languages: ["Java", "Rust"],
      topic_categories: ["Development"]
    })

    campaign =
      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new("1.00"),
        budget_daily_amount: Decimal.new(1),
        total_spend: Decimal.new("100.00"),
        start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
        end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
        creative: creative,
        audience: audience,
        included_countries: ["US"]
      )

    insert(
      :campaign,
      status: 2,
      ecpm: Decimal.new(0),
      budget_daily_amount: Decimal.new(0),
      total_spend: Decimal.new(50),
      start_date: Timex.now() |> Timex.shift(days: -4) |> DateTime.to_naive(),
      end_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
      creative: creative,
      audience: audience,
      included_countries: ["US"]
    )

    insert(
      :campaign,
      status: 2,
      ecpm: Decimal.new(1.0),
      budget_daily_amount: Decimal.new(1),
      start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
      end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
      total_spend: Decimal.new(100),
      creative: creative,
      included_countries: ["IN"],
      audience: insert(:audience, %{programming_languages: ["Java", "Rust"]})
    )

    insert(
      :campaign,
      status: 1,
      ecpm: Decimal.new(1.0),
      budget_daily_amount: Decimal.new(1),
      total_spend: Decimal.new(100),
      start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
      end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
      creative: creative,
      audience: audience,
      included_countries: ["CN"]
    )

    {:ok, %{creative: creative, campaign: campaign, audience: audience}}
  end

  describe "build/1" do
    test "it returns advertisements by property filters", %{
      campaign: campaign
    } do
      advertisement =
        AdService.Query.ForDisplay.build(
          programming_languages: ["Rust"],
          topic_categories: ["Programming"],
          client_country: "US"
        )
        |> CodeFund.Repo.one()

      assert advertisement == %AdService.Advertisement{
               body: "This is a Test Creative",
               campaign_id: campaign.id,
               headline: "winning advertisement",
               image_url: "http://example.com/some.png",
               ecpm: Decimal.new("1.00"),
               campaign_name: "Test Campaign"
             }
    end

    test "get_by_property_filters excludes indicated countries" do
      refute AdService.Query.ForDisplay.build(
               programming_languages: ["Rust"],
               topic_categories: ["Development"],
               client_country: "CN"
             )
             |> CodeFund.Repo.one()
    end
  end

  describe "build/2" do
    test "it returns advertisements by audience and country", %{
      campaign: campaign,
      audience: audience
    } do
      advertisement =
        AdService.Query.ForDisplay.build(audience, "US")
        |> CodeFund.Repo.one()

      assert advertisement == %AdService.Advertisement{
               body: "This is a Test Creative",
               campaign_id: campaign.id,
               headline: "winning advertisement",
               image_url: "http://example.com/some.png",
               ecpm: Decimal.new("1.00"),
               campaign_name: "Test Campaign"
             }
    end

    test "it does not return advertisements if no audience is passed" do
      refute AdService.Query.ForDisplay.build(nil, "US")
             |> CodeFund.Repo.one()
    end

    test "it does not return advertisements if excludes indicated countries", %{
      audience: audience
    } do
      refute AdService.Query.ForDisplay.build(audience, "IE")
             |> CodeFund.Repo.one()
    end
  end
end
