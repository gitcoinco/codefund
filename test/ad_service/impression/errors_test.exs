defmodule AdService.Impression.ErrorsTest do
  use ExUnit.Case

  describe "fetch_code/1" do
    test "it returns the error code for the corresponding atom" do
      assert AdService.Impression.Errors.fetch_code(nil) == nil
      assert AdService.Impression.Errors.fetch_code(:property_inactive) == 0
      assert AdService.Impression.Errors.fetch_code(:impression_count_exceeded) == 1
      assert AdService.Impression.Errors.fetch_code(:no_possible_ads) == 2
    end
  end

  describe "fetch_human_readable_message/1" do
    test "it returns the appropriate human readable error for the corresponding atom" do
      assert AdService.Impression.Errors.fetch_human_readable_message(:property_inactive) ==
               "This property is not currently active - code: 0"

      assert AdService.Impression.Errors.fetch_human_readable_message(:default) ==
               "This property is not currently active"

      assert AdService.Impression.Errors.fetch_human_readable_message(:impression_count_exceeded) ==
               "CodeFund does not have an advertiser for you at this time - code: 1"

      assert AdService.Impression.Errors.fetch_human_readable_message(:no_possible_ads) ==
               "CodeFund does not have an advertiser for you at this time - code: 2"
    end
  end
end
