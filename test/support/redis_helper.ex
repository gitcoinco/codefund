defmodule CodeFundWeb.RedisHelper do
  def clean_redis do
    Redix.start_link(
      host: Application.get_env(:redix, :host),
      port: Application.get_env(:redix, :port),
      database: Application.get_env(:redix, :database)
    )
    |> elem(1)
    |> Redix.command(["FLUSHDB"])
  end
end
