defmodule CodeFund.Stats.UserImpressionsTest do
  use ExUnit.Case, async: true
  use CodeFund.DataCase
  alias CodeFund.Stats.UserImpressions
  import CodeFund.Factory

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
