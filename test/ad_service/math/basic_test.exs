defmodule AdService.Math.BasicTest do
  use ExUnit.Case

  setup do
    ad_details = [
      %{
        "bid_amount" => Decimal.new(1.0),
        "body" => "ad body",
        "campaign_id" => "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
        "headline" => "ad headline",
        "image_url" => "http://example.com"
      },
      %{
        "bid_amount" => Decimal.new(0.5),
        "body" => "ad body",
        "campaign_id" => "9839afe6-5ac3-4443-be3c-dbb7a2af01e7",
        "headline" => "ad headline",
        "image_url" => "http://example.com"
      },
      %{
        "bid_amount" => Decimal.new(0.25),
        "body" => "ad body",
        "campaign_id" => "9839afe6-5ac3-4443-be3c-dbb7a2af01e8",
        "headline" => "ad headline",
        "image_url" => "http://example.com"
      }
    ]

    {:ok, %{ad_details: ad_details}}
  end

  describe "sum/2" do
    test "it returns the index + 1 of a bid_amount in a list", %{ad_details: ad_details} do
      assert AdService.Math.Basic.sum(ad_details) == 1.75
    end
  end

  describe "get_weight/2" do
    test "it returns the index + 1 of a bid_amount in a list" do
      list_of_bid_amounts = [
        %{"bid_amount" => Decimal.new("2.00")},
        %{"bid_amount" => Decimal.new("3.00")},
        %{"bid_amount" => Decimal.new("1.00")},
        %{"bid_amount" => Decimal.new("2.00")},
        %{"bid_amount" => Decimal.new("4.00")}
      ]

      assert AdService.Math.Basic.get_weight(Decimal.new("2.00"), list_of_bid_amounts) == 2
    end
  end

  describe "get_all_display_rates/1" do
    test "it returns a list of display rates sorted from greatest to least", %{
      ad_details: ad_details
    } do
      assert AdService.Math.Basic.get_all_display_rates(ad_details) == [
               %{
                 campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
                 display_rate: 61.53846153846154
               },
               %{
                 campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e8",
                 display_rate: 23.076923076923077
               },
               %{
                 campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e7",
                 display_rate: 15.384615384615385
               }
             ]
    end
  end
end
