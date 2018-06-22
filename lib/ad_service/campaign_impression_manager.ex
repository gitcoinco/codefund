defmodule AdService.CampaignImpressionManager do
  import CodeFund.Reporter

  @spec can_create_impression?(Ecto.UUID.t(), integer) ::
          {:ok, :impression_count_incremented | :impression_count_reached}
          | {:error, :impression_count_exceeded}
  def can_create_impression?(campaign_id, number_of_sold_impressions) do
    check_redis("campaign:" <> campaign_id, number_of_sold_impressions)
  end

  defp check_redis(campaign_redis_key, number_of_sold_impressions) do
    with {:ok, :impression_created} <-
           get_impression_count_for_campaign(campaign_redis_key)
           |> campaign_status(number_of_sold_impressions) do
      increment_impression_count_for_campaign(campaign_redis_key)

      {:ok, :impression_count_incremented}
    else
      {:ok, :impression_count_reached} ->
        "campaign:" <> campaign_id = campaign_redis_key

        campaign_id
        |> CodeFund.Campaigns.get_campaign!([])
        |> CodeFund.Campaigns.archive()

        increment_impression_count_for_campaign(campaign_redis_key)

        {:ok, :impression_count_reached}

      {:error, :impression_count_exceeded} ->
        report(:error, "#{campaign_redis_key} has exceeded impression count")
        {:error, :impression_count_exceeded}
    end
  end

  @spec campaign_status(integer, integer) ::
          {:ok, :impression_count_incremented | :impression_count_reached}
          | {:error, :impression_count_exceeded}

  defp campaign_status(number_of_consumed_impressions, number_of_sold_impressions)
       when number_of_consumed_impressions < number_of_sold_impressions - 1,
       do: {:ok, :impression_created}

  defp campaign_status(number_of_consumed_impressions, number_of_sold_impressions)
       when number_of_consumed_impressions == number_of_sold_impressions - 1,
       do: {:ok, :impression_count_reached}

  defp campaign_status(_number_of_consumed_impressions, _number_of_sold_impressions),
    do: {:error, :impression_count_exceeded}

  @spec increment_impression_count_for_campaign(String.t()) ::
          {:ok, Redix.Protocol.redis_value()} | {:error, atom | Redix.Error.t()}
  defp increment_impression_count_for_campaign(campaign_redis_key) do
    Redis.Pool.command(["INCR", campaign_redis_key])
  end

  @spec get_impression_count_for_campaign(String.t()) :: integer
  defp get_impression_count_for_campaign(campaign_redis_key) do
    with {:ok, [impression_count]} when not is_nil(impression_count) <-
           Redis.Pool.command(["MGET", campaign_redis_key]),
         {impression_count, _remainder} <- impression_count |> Integer.parse() do
      impression_count
    else
      {:ok, [nil]} -> 0
      :error -> :error
    end
  end
end
