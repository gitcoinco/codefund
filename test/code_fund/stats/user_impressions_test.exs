defmodule CodeFund.Stats.UserImpressionsTest do
  use ExUnit.Case, async: true
  alias CodeFund.Stats.UserImpressions

  test "last_thirty_days initial state" do
    stats = UserImpressions.last_thirty_days()

    assert stats == %CodeFund.Stats.UserImpressions.State{
             click_count: 0,
             click_rate: 0.0,
             distribution_amount: 0.0,
             impression_count: 0
           }
  end
end
