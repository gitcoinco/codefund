defmodule AdService.Math.MultiplierTest do
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

  describe "calculate/2" do
    test "it returns the index + 1 of a total_spend in a list", %{ad_details: ad_details} do
      assert AdService.Math.Multiplier.calculate(Decimal.new(50), ad_details) == 57.14285714285714
    end
  end

  describe "sum/1" do
    test "it returns the sum of the multipliers for the ad set", %{ad_details: ad_details} do
      assert AdService.Math.Multiplier.sum(ad_details) == 242.85714285714283
    end
  end
end
