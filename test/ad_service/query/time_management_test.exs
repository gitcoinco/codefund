defmodule AdService.Query.TimeManagementTest do
  use CodeFund.DataCase

  setup do
    {:ok, _pid} = TimeMachinex.ManagedClock.start()
    {:ok, %{}}
  end

  describe "where_accepted_hours_for_ip_address/2" do
    test "it allows the query to pass through unmodified if the hours are during the work day" do
      query =
        from(creative in CodeFund.Schema.Creative,
          join: campaign in Campaign,
          on: campaign.creative_id == creative.id
        )

      modified_query =
        AdService.Query.TimeManagement.where_accepted_hours_for_ip_address(
          query,
          {72, 229, 28, 185}
        )

      assert modified_query == query
    end

    test "it allows the query to pass through unmodified if there is no ip address passed in" do
      query =
        from(creative in CodeFund.Schema.Creative,
          join: campaign in Campaign,
          on: campaign.creative_id == creative.id
        )

      modified_query =
        AdService.Query.TimeManagement.where_accepted_hours_for_ip_address(query, nil)

      assert modified_query == query
    end

    test "it adds a false clause to the query if the hours are not during the work day for the given location" do
      query =
        from(creative in CodeFund.Schema.Creative,
          join: campaign in Campaign,
          on: campaign.creative_id == creative.id
        )

      modified_query =
        AdService.Query.TimeManagement.where_accepted_hours_for_ip_address(
          query,
          {95, 31, 18, 119}
        )

      assert modified_query.wheres |> List.first() |> Map.get(:expr) == %Ecto.Query.Tagged{
               tag: nil,
               type: :boolean,
               value: "1 = 0"
             }
    end
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

    test "it does not exclude the us_hours_only campaigns if the current time is not outside of us hours" do
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
