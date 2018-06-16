use Mix.Config

config :redix,
  host: System.get_env("REDIS_HOST") || "127.0.0.1",
  port: System.get_env("REDIS_PORT") || 6379,
  password: System.get_env("REDIS_PASSWORD") || nil
