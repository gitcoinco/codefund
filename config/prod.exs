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
  metabase_site_url: System.get_env("METABASE_SITE_URL"),
  metabase_secret_key: System.get_env("METABASE_SECRET_KEY"),
  iubenda_api_key: System.get_env("IUBENDA_API_KEY")

# Do not print debug messages in production
config :logger, level: :info

# Configure your database
config :code_fund, CodeFund.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :redix,
  host: Integer.parse(System.get_env("REDIS_HOST")),
  port: Integer.parse(System.get_env("REDIS_PORT")),
  password: System.get_env("REDIS_PASSWORD")

config :exq,
  name: Exq,
  host: System.get_env("REDIS_HOST"),
  port: System.get_env("REDIS_PORT"),
  password: System.get_env("REDIS_PASSWORD"),
  namespace: "exq",
  concurrency: :infinite,
  queues: [
    {"cs_high", 50},
    {"cs_default", 10},
    {"cs_low", 1}
  ],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 5,
  shutdown_timeout: 5000

config :rollbax,
  access_token: System.get_env("ROLLBAR_ACCESS_TOKEN"),
  environment: "production"

config :code_fund, CodeFund.Mailer,
  adapter: Bamboo.MailgunAdapter,
  api_key: System.get_env("MAILGUN_API_KEY") || "MISSING",
  domain: System.get_env("MAILGUN_DOMAIN") || "MISSING"

config :redix, database: 1
