defmodule AdService.ImpressionCache do
  @spec lookup(tuple, UUID.t()) :: {:ok, :cache_loaded, map} | {:error, :no_cache_found}
  def lookup(ip, property_id) do
    redis_key = get_redis_key(ip, property_id)

    case Redis.Pool.command(["GET", redis_key]) do
      {:ok, nil} -> {:error, :no_cache_found}
      {:ok, payload} -> {:ok, :cache_loaded, payload |> Poison.decode!()}
    end
  end

  @spec store(map, tuple, UUID.t()) :: {:ok, :cache_stored}
  def store(payload, ip, property_id) do
    redis_key = get_redis_key(ip, property_id)

    {:ok, _} =
      Redis.Pool.command([
        "SET",
        redis_key,
        payload |> Poison.encode!(),
        "EX",
        Application.get_env(:code_fund, :ad_cache_timeout)
      ])

    {:ok, :cache_stored}
  end

  @spec get_redis_key(tuple, UUID.t()) :: String.t()
  defp get_redis_key(ip, property_id) do
    ip_string = ip |> Tuple.to_list() |> Enum.join(".")
    "#{ip_string}/#{property_id}"
  end
end
