defmodule AdService.Query.TimeManagementTest do
  use CodeFund.DataCase

  setup do
    {:ok, _pid} = TimeMachinex.ManagedClock.start()
    {:ok, %{}}
  end

  describe "optionally_exclude_us_hours_only_campaigns/1" do
    test "it excludes the us_hours_only campaigns if the current time is outside of us hours" do
      TimeMachinex.ManagedClock.set(DateTime.from_naive!(~N[1985-10-26 11:00:00], "Etc/UTC"))

      query =
        from(creative in CodeFund.Schema.Creative,
          join: campaign in Campaign,
          on: campaign.creative_id == creative.id
        )
        |> AdService.Query.TimeManagement.optionally_exclude_us_hours_only_campaigns()

      assert query.__struct__ == Ecto.Query
      [us_hours_wheres] = query.wheres

      assert us_hours_wheres.expr ==
               {:==, [],
                [
                  {{:., [], [{:&, [], [1]}, :us_hours_only]}, [], []},
                  %Ecto.Query.Tagged{
                    tag: nil,
                    type: {1, :us_hours_only},
                    value: false
                  }
                ]}

      assert us_hours_wheres.op == :and
    end

    test "it does not the us_hours_only campaigns if the current time is not outside of us hours" do
      TimeMachinex.ManagedClock.set(DateTime.from_naive!(~N[1985-10-26 13:00:00], "Etc/UTC"))

      query =
        from(creative in CodeFund.Schema.Creative,
          join: campaign in Campaign,
          on: campaign.creative_id == creative.id
        )
        |> AdService.Query.TimeManagement.optionally_exclude_us_hours_only_campaigns()

      assert query.__struct__ == Ecto.Query
      assert query.wheres == []
    end
  end
end
