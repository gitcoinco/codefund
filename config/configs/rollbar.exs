use Mix.Config

config :rollbax,
  enabled: false,
  access_token: System.get_env("ROLLBAR_TOKEN")