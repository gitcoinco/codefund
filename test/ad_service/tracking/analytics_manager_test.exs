defmodule AdService.Tracking.AnalyticsManagerTest do
  use CodeFund.DataCase, async: true
  import CodeFund.Factory

  describe "send_event/1" do
    # JBEAN TODO: Is there a more interesting test we can do here?
    test "it imports the geoid csv into an ets table" do
      impression = insert(:impression, %{city: "Boulder", region: "Colorado", country: "US"})
      assert :ok == AdService.Tracking.AnalyticsManager.send_event(impression)
    end
  end
end
