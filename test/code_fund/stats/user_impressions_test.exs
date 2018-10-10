defmodule CodeFund.Stats.UserImpressionsTest do
  use CodeFund.DataCase
  alias CodeFund.Stats.UserImpressions

  test "last_thirty_days initial state" do
    stats = UserImpressions.last_thirty_days()
    assert stats.click_count == 0
    assert stats.click_rate == 0.0
    assert stats.distribution_amount == 0.0
    assert stats.impression_count == 0
  end

  test "stats update after :refresh message sent to genserver" do
    pid = Process.whereis(UserImpressions)
    Process.send(pid, :refresh, [])
    stats = UserImpressions.last_thirty_days()
    assert stats.refreshed_at != nil
  end
end
