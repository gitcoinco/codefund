use Mix.Config

config :sentry,
  dsn: System.get_env("SENTRY_DSN") || "",
  included_environments: [:prod],
  environment_name: Mix.env()
