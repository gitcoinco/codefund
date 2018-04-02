use Mix.Config

config :rollbax,
  enabled: true,
  access_token: System.get_env("ROLLBAR_ACCESS_TOKEN") || "None",
  enable_crash_reports: true
