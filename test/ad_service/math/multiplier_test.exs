defmodule AdService.Math.MultiplierTest do
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

  describe "calculate/2" do
    test "it returns the index + 1 of a bid_amount in a list", %{ad_details: ad_details} do
      assert AdService.Math.Multiplier.calculate(Decimal.new(0.5), ad_details) ==
               28.57142857142857
    end
  end

  describe "sum/1" do
    test "it returns the sum of the multipliers for the ad set", %{ad_details: ad_details} do
      assert AdService.Math.Multiplier.sum(ad_details) == 185.7142857142857
    end
  end
end
