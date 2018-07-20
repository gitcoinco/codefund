defmodule AdService.ImpressionCacheTest do
  use ExUnit.Case

  setup do
    on_exit(fn -> CodeFundWeb.RedisHelper.clean_redis() end)
    property_uuid = UUID.uuid4()
    redis_key = "1.2.3.4/" <> property_uuid
    {:ok, %{property_uuid: property_uuid, ip: {1, 2, 3, 4}, redis_key: redis_key}}
  end

  describe("lookup/2") do
    test "it returns {:ok, payload} if a cache exists in redis", %{
      property_uuid: property_uuid,
      ip: ip,
      redis_key: redis_key
    } do
      Redis.Pool.command(["SET", redis_key, %{foo: :bar} |> Poison.encode!(), "EX", 30])

      {:ok, :cache_loaded, payload} = AdService.ImpressionCache.lookup(ip, property_uuid)
      assert payload == %{"foo" => "bar"}
    end

    test "it returns {:error, :no_cache_found} if no cache exists in redis", %{
      property_uuid: property_uuid,
      ip: ip
    } do
      assert {:error, :no_cache_found} = AdService.ImpressionCache.lookup(ip, property_uuid)
    end
  end

  describe("store/3") do
    test "it successfully stores a cache and returns {:ok, :cache_stored} when storing a cache in the redis db",
         %{property_uuid: property_uuid, ip: ip, redis_key: redis_key} do
      assert {:ok, :cache_stored} ==
               AdService.ImpressionCache.store(%{foo: :bar}, ip, property_uuid)

      assert {:ok, "{\"foo\":\"bar\"}"} == Redis.Pool.command(["GET", redis_key])
    end
  end
end
