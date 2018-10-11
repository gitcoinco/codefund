defmodule AdService.Query.ForDisplayTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  setup do
    {:ok, _pid} = TimeMachinex.ManagedClock.start()

    creative =
      insert(:creative, headline: "winning advertisement", wide_image_asset: insert(:asset))

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

    property =
      insert(:property, %{
        programming_languages: ["Ruby", "C"],
        topic_categories: ["Programming"]
      })

    insert(:property, %{
      programming_languages: ["Ruby", "C"],
      topic_categories: ["Development"]
    })

    insert(:property, %{
      programming_languages: ["Ruby", "Rust"],
      topic_categories: ["Programming"]
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
        included_programming_languages: ["Ruby"],
        included_topic_categories: ["Programming"],
        excluded_programming_languages: ["Rust"],
        excluded_topic_categories: ["Development"],
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
      included_programming_languages: ["Rust"],
      included_topic_categories: ["Development"],
      excluded_programming_languages: ["Ruby"],
      excluded_topic_categories: ["Programming"],
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
      included_programming_languages: ["Rust"],
      included_topic_categories: ["Development"],
      excluded_programming_languages: ["Ruby"],
      excluded_topic_categories: ["Programming"],
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
      included_programming_languages: ["Rust"],
      included_topic_categories: ["Development"],
      excluded_programming_languages: ["Ruby"],
      excluded_topic_categories: ["Programming"],
      included_countries: ["CN"]
    )

    [cdn_host: cdn_host] = Application.get_env(:code_fund, Framework.FileStorage)

    {:ok,
     %{
       audience: audience,
       creative: creative,
       campaign: campaign,
       cdn_host: cdn_host,
       property: property
     }}
  end

  describe "fallback_ad_by_property_id/1" do
    test "it returns advertisements for the fallback ad in the audience the property is associated with",
         %{cdn_host: cdn_host} do
      fallback_campaign = insert(:campaign)

      property =
        insert(:property, audience: insert(:audience, fallback_campaign_id: fallback_campaign.id))

      assert AdService.Query.ForDisplay.fallback_ad_by_property_id(property.id) ==
               %AdService.UnrenderedAdvertisement{
                 body: "This is a Test Creative",
                 campaign_id: fallback_campaign.id,
                 headline: "Creative Headline",
                 ecpm: Decimal.new("2.00"),
                 campaign_name: "Test Campaign",
                 images: [
                   %AdService.ImageAsset{
                     height: 200,
                     size_descriptor: "small",
                     url: "https://#{cdn_host}/image.jpg",
                     width: 200
                   },
                   %AdService.ImageAsset{
                     height: 200,
                     size_descriptor: "large",
                     url: "https://#{cdn_host}/image.jpg",
                     width: 280
                   }
                 ]
               }
    end
  end

  describe "build/1" do
    test "get_by_property_filters excludes indicated countries", %{property: property} do
      refute AdService.Query.ForDisplay.build(property, "CN", nil, ["Foobar"])
             |> CodeFund.Repo.one()
    end

    test "it returns advertisements by audience, included country and excluded advertisers", %{
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
        included_programming_languages: ["Ruby"],
        included_topic_categories: ["Programming"],
        excluded_programming_languages: ["Rust"],
        excluded_topic_categories: ["Development"],
        included_countries: ["US"],
        user: insert(:user, company: "Foobar")
      )

      property =
        insert(:property, %{
          programming_languages: ["Ruby", "C"],
          topic_categories: []
        })

      advertisement =
        AdService.Query.ForDisplay.build(property, "US", nil, ["Foobar"])
        |> CodeFund.Repo.one()

      small_image_asset = CodeFund.Schema.Asset |> Repo.get!(creative.small_image_asset.id)
      large_image_asset = CodeFund.Schema.Asset |> Repo.get!(creative.large_image_asset.id)
      wide_image_asset = CodeFund.Schema.Asset |> Repo.get!(creative.wide_image_asset.id)

      assert advertisement == %AdService.UnrenderedAdvertisement{
               body: "This is a Test Creative",
               campaign_id: campaign.id,
               headline: "winning advertisement",
               ecpm: Decimal.new("1.00"),
               campaign_name: "Test Campaign",
               images: [
                 %AdService.UnprocessedImageAsset{
                   asset: small_image_asset,
                   size_descriptor: "small"
                 },
                 %AdService.UnprocessedImageAsset{
                   asset: large_image_asset,
                   size_descriptor: "large"
                 },
                 %AdService.UnprocessedImageAsset{
                   asset: wide_image_asset,
                   size_descriptor: "wide"
                 }
               ]
             }
    end

    test "it excludes campaigns which are not allowed on the weekends when its a weekend", %{
      property: property,
      creative: creative
    } do
      CodeFund.Schema.Campaign
      |> CodeFund.Repo.all()
      |> Enum.map(&CodeFund.Campaigns.delete_campaign(&1))

      insert(
        :campaign,
        status: 2,
        ecpm: Decimal.new("1.00"),
        budget_daily_amount: Decimal.new(1),
        total_spend: Decimal.new("100.00"),
        start_date: Timex.now() |> Timex.shift(days: -1) |> DateTime.to_naive(),
        end_date: Timex.now() |> Timex.shift(days: 1) |> DateTime.to_naive(),
        creative: creative,
        weekdays_only: true,
        included_programming_languages: ["Ruby"],
        included_topic_categories: ["Programming"],
        excluded_programming_languages: ["Rust"],
        excluded_topic_categories: ["Development"],
        included_countries: ["US"],
        user: insert(:user, company: "Acme")
      )

      TimeMachinex.ManagedClock.set(DateTime.from_naive!(~N[2018-09-22 11:00:00], "Etc/UTC"))

      advertisement =
        AdService.Query.ForDisplay.build(property, "US", {72, 229, 28, 185}, ["Foobar"])
        |> CodeFund.Repo.one()

      refute advertisement
    end

    test "it will exclude campaigns that are over their daily budget", %{
      property: property,
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
          included_programming_languages: ["Ruby"],
          included_topic_categories: ["Programming"],
          excluded_programming_languages: ["Rust"],
          excluded_topic_categories: ["Development"],
          included_countries: ["US"],
          user: insert(:user, company: "Acme")
        )

      insert(:impression, campaign: campaign, revenue_amount: Decimal.new(9.5))

      advertisement =
        AdService.Query.ForDisplay.build(property, "US", nil, ["Foobar"]) |> CodeFund.Repo.one()

      refute advertisement
    end
  end
end
