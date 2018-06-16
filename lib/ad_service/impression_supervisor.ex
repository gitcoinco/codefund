defmodule AdService.ImpressionSupervisor do
  use GenServer
  import CodeFund.Reporter

  @spec start_link() :: :ignore | {:error, any} | {:ok, pid()}
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(:ok) :: {:ok, [redis_connection: pid()]}
  def init(:ok) do
    {:ok, redis_connection} =
      Redix.start_link(
        host: Application.get_env(:redix, :host),
        port: Application.get_env(:redix, :port),
        database: Application.get_env(:redix, :database),
        password: Application.get_env(:redix, :password)
      )

    {:ok, [redis_connection: redis_connection]}
  end

  @spec can_create_impression?(Ecto.UUID.t(), integer) ::
          {:ok, :impression_count_incremented | :impression_count_reached}
          | {:error, :impression_count_exceeded}
  def can_create_impression?(campaign_id, number_of_sold_impressions) do
    GenServer.call(
      __MODULE__,
      {:can_create_impression, "campaign:" <> campaign_id, number_of_sold_impressions}
    )
  end

  def handle_call(
        {:can_create_impression, campaign_redis_key, number_of_sold_impressions},
        _from,
        [redis_connection: redis_connection] = connection_list
      ) do
    with {:ok, :impression_created} <-
           redis_connection
           |> get_impression_count_for_campaign(campaign_redis_key)
           |> campaign_status(number_of_sold_impressions) do
      redis_connection
      |> increment_impression_count_for_campaign(campaign_redis_key)

      {:reply, {:ok, :impression_count_incremented}, connection_list}
    else
      {:ok, :impression_count_reached} ->
        "campaign:" <> campaign_id = campaign_redis_key

        campaign_id
        |> CodeFund.Campaigns.get_campaign!([])
        |> CodeFund.Campaigns.archive()

        redis_connection
        |> increment_impression_count_for_campaign(campaign_redis_key)

        {:reply, {:ok, :impression_count_reached}, connection_list}

      {:error, :impression_count_exceeded} ->
        report(:error, "#{campaign_redis_key} has exceeded impression count")
        {:reply, {:error, :impression_count_exceeded}, connection_list}
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

  @spec increment_impression_count_for_campaign(pid(), String.t()) :: :ok
  defp increment_impression_count_for_campaign(conn, campaign_redis_key) do
    conn
    |> Redix.command(["INCR", campaign_redis_key])
  end

  @spec get_impression_count_for_campaign(pid(), String.t()) :: integer :: :error
  defp get_impression_count_for_campaign(conn, campaign_redis_key) do
    with {:ok, [impression_count]} when not is_nil(impression_count) <-
           conn |> Redix.command(["MGET", campaign_redis_key]),
         {impression_count, _remainder} <- impression_count |> Integer.parse() do
      impression_count
    else
      {:ok, [nil]} -> 0
    end
  end
end
