use Mix.Config

config :redix,
  host: System.get_env("REDIS_HOST") || "127.0.0.1",
  port: 6379
