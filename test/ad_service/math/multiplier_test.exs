defmodule AdService.Math.MultiplierTest do
  use ExUnit.Case

  setup do
    ad_details = [
      %AdService.UnrenderedAdvertisement{
        ecpm: Decimal.new(2.50),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
        headline: "ad headline"
      },
      %AdService.UnrenderedAdvertisement{
        ecpm: Decimal.new(3.00),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e7",
        headline: "ad headline"
      },
      %AdService.UnrenderedAdvertisement{
        ecpm: Decimal.new(3.50),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e8",
        headline: "ad headline"
      }
    ]

    {:ok, %{ad_details: ad_details}}
  end

  describe "calculate/2" do
    test "it returns the index + 1 of a ecpm in a list", %{ad_details: ad_details} do
      assert AdService.Math.Multiplier.calculate(Decimal.new(3.50), ad_details) ==
               116.66666666666669
    end
  end

  describe "sum/1" do
    test "it returns the sum of the multipliers for the ad set", %{ad_details: ad_details} do
      assert AdService.Math.Multiplier.sum(ad_details) == 211.11111111111111
    end
  end
end
