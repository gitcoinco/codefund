defmodule Redis.Pool do
  @spec command(list) :: {:ok, list | nil}
  def command(commands) do
    pid = :poolboy.checkout(:redis_pool)

    {:ok, result} =
      pid
      |> Redix.command(commands)

    :poolboy.checkin(:redis_pool, pid)
    {:ok, result}
  end
end
