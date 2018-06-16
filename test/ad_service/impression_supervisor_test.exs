defmodule AdService.ImpressionSupervisorTest do
  use CodeFund.DataCase
  import CodeFund.Factory

  setup do
    date_stub = Timex.now() |> DateTime.to_naive()
    campaign = insert(:campaign, status: 2, start_date: date_stub, end_date: date_stub)

    {:ok, redis_connection} =
      Redix.start_link(
        host: Application.get_env(:redix, :host),
        port: Application.get_env(:redix, :port),
        database: 15
      )

    on_exit(fn -> CodeFundWeb.RedisHelper.clean_redis() end)
    {:ok, %{redis_connection: redis_connection, campaign: campaign}}
  end

  describe("can_create_impression?/2") do
    test "it returns {:ok, :impression_count_incremented} if it's able to increment a campaign's impression count" do
      assert {:ok, :impression_count_incremented} ==
               AdService.ImpressionSupervisor.can_create_impression?("somecampaign", 100)
    end

    test "it returns {:ok, :impression_count_reached} if the current impression will cause the campaign to hit its limit",
         %{redis_connection: redis_connection, campaign: campaign} do
      redis_connection
      |> Redix.command(["SET", "campaign:#{campaign.id}", "99"])

      assert {:ok, :impression_count_reached} ==
               AdService.ImpressionSupervisor.can_create_impression?("#{campaign.id}", 100)
    end

    test "it returns {:error, :impression_count_exceeded} if the current impression will cause the campaign to exceed its limit",
         %{redis_connection: redis_connection, campaign: campaign} do
      redis_connection
      |> Redix.command(["SET", "campaign:#{campaign.id}", "100"])

      assert {:error, :impression_count_exceeded} ==
               AdService.ImpressionSupervisor.can_create_impression?("#{campaign.id}", 100)

      assert redis_connection
             |> Redix.command(["MGET", "campaign:#{campaign.id}"]) == {:ok, ["100"]}
    end
  end
end
