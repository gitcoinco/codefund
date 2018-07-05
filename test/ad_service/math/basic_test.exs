defmodule AdService.Math.BasicTest do
  use ExUnit.Case

  setup do
    ad_details = [
      %AdService.Advertisement{
        ecpm: Decimal.new(2.50),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
        campaign_name: "Campaign 1",
        headline: "ad headline",
        image_url: "http://example.com"
      },
      %AdService.Advertisement{
        ecpm: Decimal.new(3.00),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e7",
        campaign_name: "Campaign 2",
        headline: "ad headline",
        image_url: "http://example.com"
      },
      %AdService.Advertisement{
        ecpm: Decimal.new(3.50),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e8",
        campaign_name: "Campaign 3",
        headline: "ad headline",
        image_url: "http://example.com"
      }
    ]

    {:ok, %{ad_details: ad_details}}
  end

  describe "sum/2" do
    test "it returns the sum of ecpms in a list", %{ad_details: ad_details} do
      assert AdService.Math.Basic.sum(ad_details) == 9.0
    end
  end

  describe "get_weight/2" do
    test "it returns the index + 1 of an ecpm in a list" do
      list_of_ecpms = [
        %AdService.Advertisement{ecpm: Decimal.new(2.0)},
        %AdService.Advertisement{ecpm: Decimal.new(3.0)},
        %AdService.Advertisement{ecpm: Decimal.new(1.0)},
        %AdService.Advertisement{ecpm: Decimal.new(2.0)},
        %AdService.Advertisement{ecpm: Decimal.new(4.0)}
      ]

      assert AdService.Math.Basic.get_weight(Decimal.new(2.0), list_of_ecpms) == 2
    end
  end

  describe "get_all_display_rates/1" do
    test "it returns a list of display rates sorted from greatest to least", %{
      ad_details: ad_details
    } do
      assert AdService.Math.Basic.get_all_display_rates(ad_details) == [
               %{
                 campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e8",
                 display_rate: 55.26315789473685,
                 campaign_name: "Campaign 3"
               },
               %{
                 campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e7",
                 display_rate: 31.578947368421044,
                 campaign_name: "Campaign 2"
               },
               %{
                 campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
                 display_rate: 13.157894736842104,
                 campaign_name: "Campaign 1"
               }
             ]
    end
  end
end
