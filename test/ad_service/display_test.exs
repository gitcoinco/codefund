defmodule AdService.DisplayTest do
  use ExUnit.Case

  setup do
    winning_ad = %{
      "bid_amount" => Decimal.new(0.8),
      "body" => "ad body",
      "campaign_id" => "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
      "headline" => "ad headline",
      "image_url" => "http://example.com"
    }

    possible_ads_set_of_two = [
      %{
        "bid_amount" => Decimal.new(0.8),
        "body" => "ad body",
        "campaign_id" => "9839afe6-5ac3-4443-be3c-dbb7a2af01e7",
        "headline" => "ad headline",
        "image_url" => "http://example.com"
      },
      winning_ad
    ]

    {:ok, %{winning_ad: winning_ad, possible_ads_set_of_two: possible_ads_set_of_two}}
  end

  describe "render/1" do
    test "it returns the map of things from the campaign id it's passed", %{
      winning_ad: winning_ad,
      possible_ads_set_of_two: possible_ads_set_of_two
    } do
      assert AdService.Display.render(
               {possible_ads_set_of_two, {"9839afe6-5ac3-4443-be3c-dbb7a2af01e6", nil}}
             ) == winning_ad
    end
  end

  describe "choose_winner/1" do
    test "it returns a winning ad and the list of possible ads if passed a list" do
      possible_ads = [
        %{
          "bid_amount" => Decimal.new(0.8),
          "body" => "ad body",
          "campaign_id" => "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
          "headline" => "ad headline",
          "image_url" => "http://example.com"
        }
      ]

      assert AdService.Display.choose_winner(possible_ads) ==
               {:ok,
                {
                  possible_ads,
                  {"9839afe6-5ac3-4443-be3c-dbb7a2af01e6", 0..100}
                }}
    end

    test "it correctly calculates the probability of each ad in a set showing", %{
      possible_ads_set_of_two: possible_ads_set_of_two
    } do
      {:ok,
       {
         _possible_ads_set_of_two,
         {_uuid, starting_point..ending_point}
       }} = AdService.Display.choose_winner(possible_ads_set_of_two)

      assert ending_point - starting_point == 50
    end

    test "it returns an error if there are no ads that can be shown on a property" do
      assert AdService.Display.choose_winner([]) == {:error, :no_possible_ads}
    end
  end
end
