use Mix.Config

config :code_fund, CodeFundWeb.Endpoint,
  load_from_system_env: true,
  url: [
    scheme: "https",
    host: System.get_env("HOST") || "codefund.io",
    port: System.get_env("PORT")
  ],
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  cache_static_manifest: "priv/static/manifest.json",
  secret_key_base: Map.fetch!(System.get_env(), "SECRET_KEY_BASE"),
  ga_tracking_id: System.get_env("GA_TRACKING_ID"),
  iubenda_api_key: System.get_env("IUBENDA_API_KEY")

# Do not print debug messages in production
config :logger, level: :info

# Configure your database
config :code_fund, CodeFund.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true,
  loggers: [Appsignal.Ecto, Ecto.LogEntry]

config :redix,
  host: System.get_env("REDIS_HOST"),
  port: String.to_integer(System.get_env("REDIS_PORT")),
  password: System.get_env("REDIS_PASSWORD")

config :code_fund, CodeFund.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("MAILGUN_API_KEY") || "MISSING",
  domain: System.get_env("MAILGUN_DOMAIN") || "MISSING"

config :redix, database: System.get_env("REDIS_DATABASE")

config :time_machinex, TimeMachinex, adapter: TimeMachinex.SystemClock

config :ex_aws,
  region: System.get_env("S3_REGION"),
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  bucket: System.get_env("S3_BUCKET")
