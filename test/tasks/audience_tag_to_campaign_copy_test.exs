defmodule Mix.Tasks.AudienceTagToCampaign.CopyTest do
  use CodeFund.DataCase
  import CodeFund.Factory
  alias CodeFund.Campaigns

  setup do
    date_stub = Timex.now() |> DateTime.to_naive()

    audience =
      insert(:audience, programming_languages: ["PHP", "MySQL"], topic_categories: ["Programming"])

    campaign =
      insert(:campaign,
        audience_id: audience.id,
        included_programming_languages: [],
        included_topic_categories: [],
        excluded_programming_languages: [],
        excluded_topic_categories: [],
        start_date: date_stub,
        end_date: date_stub
      )

    audience_2 =
      insert(:audience, programming_languages: ["Ruby"], topic_categories: ["Frontend", "Backend"])

    campaign_2 =
      insert(:campaign,
        audience_id: audience_2.id,
        included_programming_languages: [],
        included_topic_categories: [],
        excluded_programming_languages: [],
        excluded_topic_categories: [],
        start_date: date_stub,
        end_date: date_stub
      )

    campaign_3 =
      insert(:campaign,
        included_programming_languages: [],
        included_topic_categories: [],
        excluded_programming_languages: [],
        excluded_topic_categories: [],
        start_date: date_stub,
        end_date: date_stub
      )

    {:ok,
     %{
       audience: audience,
       audience_2: audience_2,
       campaign: campaign,
       campaign_2: campaign_2,
       campaign_3: campaign_3
     }}
  end

  describe ".run/1" do
    test "it copies tags from audiences to the campaigns that they belong to", %{
      audience: audience,
      audience_2: audience_2,
      campaign: campaign,
      campaign_2: campaign_2,
      campaign_3: campaign_3
    } do
      Mix.Tasks.AudienceTagToCampaign.Copy.run(nil)

      assert Campaigns.get_campaign!(campaign.id, []).included_programming_languages ==
               audience.programming_languages

      assert Campaigns.get_campaign!(campaign.id, []).included_topic_categories ==
               audience.topic_categories

      assert Campaigns.get_campaign!(campaign.id, []).excluded_programming_languages == []
      assert Campaigns.get_campaign!(campaign.id, []).excluded_topic_categories == []

      assert Campaigns.get_campaign!(campaign_2.id, []).included_programming_languages ==
               audience_2.programming_languages

      assert Campaigns.get_campaign!(campaign_2.id, []).included_topic_categories ==
               audience_2.topic_categories

      assert Campaigns.get_campaign!(campaign_2.id, []).excluded_programming_languages == []
      assert Campaigns.get_campaign!(campaign_2.id, []).excluded_topic_categories == []

      assert Campaigns.get_campaign!(campaign_3.id, []).included_programming_languages == []
      assert Campaigns.get_campaign!(campaign_3.id, []).included_topic_categories == []
      assert Campaigns.get_campaign!(campaign_3.id, []).excluded_programming_languages == []
      assert Campaigns.get_campaign!(campaign_3.id, []).excluded_topic_categories == []
    end
  end
end
