defmodule AdService.Math.BasicTest do
  use ExUnit.Case

  setup do
    ad_details = [
      %AdService.Advertisement{
        total_spend: Decimal.new(100),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
        headline: "ad headline",
        image_url: "http://example.com"
      },
      %AdService.Advertisement{
        total_spend: Decimal.new(50),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e7",
        headline: "ad headline",
        image_url: "http://example.com"
      },
      %AdService.Advertisement{
        total_spend: Decimal.new(25),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e8",
        headline: "ad headline",
        image_url: "http://example.com"
      }
    ]

    {:ok, %{ad_details: ad_details}}
  end

  describe "sum/2" do
    test "it returns the index + 1 of a total_spend in a list", %{ad_details: ad_details} do
      assert AdService.Math.Basic.sum(ad_details) == 175.0
    end
  end

  describe "get_weight/2" do
    test "it returns the index + 1 of a total_spend in a list" do
      list_of_total_spends = [
        %AdService.Advertisement{total_spend: Decimal.new(200)},
        %AdService.Advertisement{total_spend: Decimal.new(300)},
        %AdService.Advertisement{total_spend: Decimal.new(100)},
        %AdService.Advertisement{total_spend: Decimal.new(200)},
        %AdService.Advertisement{total_spend: Decimal.new(400)}
      ]

      assert AdService.Math.Basic.get_weight(Decimal.new(200), list_of_total_spends) == 2
    end
  end

  describe "get_all_display_rates/1" do
    test "it returns a list of display rates sorted from greatest to least", %{
      ad_details: ad_details
    } do
      assert AdService.Math.Basic.get_all_display_rates(ad_details) == [
               %{
                 campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
                 display_rate: 70.58823529411765
               },
               %{
                 campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e7",
                 display_rate: 23.52941176470588
               },
               %{
                 campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e8",
                 display_rate: 5.88235294117647
               }
             ]
    end
  end
end
