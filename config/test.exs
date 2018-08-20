use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :code_fund, CodeFundWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :code_fund, CodeFund.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "",
  database: "code_fund_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :code_fund, CodeFund.Mailer, adapter: Bamboo.TestAdapter

config :code_fund, CodeFundWeb.Endpoint, slack_token: nil

config :redix, database: 15

config :ex_aws,
  region: "fakes3",
  access_key_id: "123",
  secret_access_key: "asdf",
  bucket: "stub"

config :ex_aws, :s3,
  scheme: "http://",
  host: "localhost",
  port: 4567

config :appsignal, :config, active: false

config :code_fund, AdService.Tracking.AnalyticsManager,
  google_analytics_property_id: "SomeStubPropertyID"
