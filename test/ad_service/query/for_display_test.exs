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
        included_countries: ["US"],
        user: insert(:user, company: "Acme")
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

    {:ok, %{audience: audience, creative: creative, campaign: campaign}}
  end

  describe "fallback_ad_by_property_id/1" do
    test "it returns advertisements for the fallback ad in the audience the property is associated with" do
      fallback_campaign = insert(:campaign)

      property =
        insert(:property, audience: insert(:audience, fallback_campaign_id: fallback_campaign.id))

      assert AdService.Query.ForDisplay.fallback_ad_by_property_id(property.id) ==
               %AdService.Advertisement{
                 body: "This is a Test Creative",
                 campaign_id: fallback_campaign.id,
                 headline: "Creative Headline",
                 image_url: "http://example.com/some.png",
                 ecpm: Decimal.new("2.00"),
                 campaign_name: "Test Campaign",
                 small_image_object: nil,
                 large_image_object: "image.jpg"
               }
    end
  end

  describe "build/1" do
    test "get_by_property_filters excludes indicated countries", %{audience: audience} do
      refute AdService.Query.ForDisplay.build(audience, "CN", ["Foobar"]) |> CodeFund.Repo.one()
    end

    test "it returns advertisements by audience, included country and excluded advertisers", %{
      audience: audience,
      campaign: campaign,
      creative: creative
    } do
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
        included_countries: ["US"],
        user: insert(:user, company: "Foobar")
      )

      advertisement =
        AdService.Query.ForDisplay.build(audience, "US", ["Foobar"]) |> CodeFund.Repo.one()

      assert advertisement == %AdService.Advertisement{
               body: "This is a Test Creative",
               campaign_id: campaign.id,
               headline: "winning advertisement",
               image_url: "http://example.com/some.png",
               ecpm: Decimal.new("1.00"),
               campaign_name: "Test Campaign",
               small_image_object: nil,
               large_image_object: "image.jpg"
             }
    end

    test "it will exclude campaigns that are over their daily budget", %{
      audience: audience,
      creative: creative
    } do
      CodeFund.Schema.Campaign
      |> CodeFund.Repo.all()
      |> Enum.map(&CodeFund.Campaigns.delete_campaign(&1))

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
          included_countries: ["US"],
          user: insert(:user, company: "Acme")
        )

      insert(:impression, campaign: campaign, revenue_amount: Decimal.new(9.5))

      advertisement =
        AdService.Query.ForDisplay.build(audience, "US", ["Foobar"]) |> CodeFund.Repo.one()

      refute advertisement
    end
  end
end
