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
