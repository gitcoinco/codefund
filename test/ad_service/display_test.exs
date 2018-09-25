defmodule AdService.DisplayTest do
  use ExUnit.Case

  setup do
    winning_ad = %AdService.UnrenderedAdvertisement{
      ecpm: Decimal.new(10),
      body: "ad body",
      campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e6",
      headline: "ad headline"
    }

    possible_ads_set_of_two = [
      %AdService.UnrenderedAdvertisement{
        ecpm: Decimal.new(1),
        body: "ad body",
        campaign_id: "9839afe6-5ac3-4443-be3c-dbb7a2af01e7",
        headline: "ad headline"
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
    test "it returns a winning ad and the list of possible ads if passed a list", %{
      possible_ads_set_of_two: possible_ads_set_of_two
    } do
      {:ok,
       {
         ^possible_ads_set_of_two,
         winning_ad
       }} = AdService.Display.choose_winner(possible_ads_set_of_two)

      assert winning_ad == {"9839afe6-5ac3-4443-be3c-dbb7a2af01e6", 0..95} or
               {"9839afe6-5ac3-4443-be3c-dbb7a2af01e7", 95..99}
    end

    test "it correctly calculates the probability of each ad in a set showing", %{
      possible_ads_set_of_two: possible_ads_set_of_two
    } do
      {:ok,
       {
         ^possible_ads_set_of_two,
         {uuid, starting_point..ending_point}
       }} = AdService.Display.choose_winner(possible_ads_set_of_two)

      case uuid do
        "9839afe6-5ac3-4443-be3c-dbb7a2af01e6" -> assert ending_point - starting_point == 95
        "9839afe6-5ac3-4443-be3c-dbb7a2af01e7" -> assert ending_point - starting_point == 4
      end
    end

    test "it returns an error if there are no ads that can be shown on a property" do
      assert AdService.Display.choose_winner([]) == {:error, :no_possible_ads}
    end
  end
end
