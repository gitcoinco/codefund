defmodule AdService.ImpressionSupervisor do
  use GenServer
  import CodeFund.Reporter

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, redis_connection} =
      Redix.start_link(
        host: Application.get_env(:redix, :host),
        port: Application.get_env(:redix, :port)
      )

    {:ok, [redis_connection: redis_connection]}
  end

  def can_create_impression?(campaign, number_of_sold_impressions) do
    GenServer.call(
      __MODULE__,
      {:can_create_impression, "campaign:" <> campaign, number_of_sold_impressions}
    )
  end

  def handle_call(
        {:can_create_impression, campaign, number_of_sold_impressions},
        _from,
        [redis_connection: redis_connection] = connection_list
      ) do
    with {:ok, :impression_created} <-
           redis_connection
           |> get_value_of_campaign(campaign)
           |> campaign_status(number_of_sold_impressions) do
      redis_connection
      |> increment_campaign(campaign)

      {:reply, {:ok, :impression_count_incremented}, connection_list}
    else
      {:ok, :impression_count_reached} ->
        "campaign:" <> campaign_id = campaign

        campaign_id
        |> CodeFund.Campaigns.get_campaign!([])
        |> CodeFund.Campaigns.archive()

        redis_connection
        |> increment_campaign(campaign)

        {:reply, {:ok, :impression_count_reached}, connection_list}

      {:error, :impression_count_exceeded} ->
        report(:error, "#{campaign} has exceeded impression count")
        {:reply, {:error, :impression_count_exceeded}, connection_list}
    end
  end

  defp campaign_status(number_of_consumed_impressions, number_of_sold_impressions)
       when number_of_consumed_impressions < (number_of_sold_impressions - 1),
       do: {:ok, :impression_created}

  defp campaign_status(number_of_consumed_impressions, number_of_sold_impressions)
       when number_of_consumed_impressions == (number_of_sold_impressions - 1),
       do: {:ok, :impression_count_reached}

  defp campaign_status(_number_of_consumed_impressions, _number_of_sold_impressions),
    do: {:error, :impression_count_exceeded}

  defp increment_campaign(conn, campaign) do
    conn
    |> Redix.command(["INCR", campaign])
  end

  defp get_value_of_campaign(conn, campaign) do
    with {:ok, [value]} when not is_nil(value) <- conn |> Redix.command(["MGET", campaign]),
         {value, _remainder} <- value |> Integer.parse() do
      value
    else
      {:ok, [nil]} -> 0
      :error -> :error
    end
  end
end
