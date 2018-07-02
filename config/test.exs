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

config :code_fund, Authentication.Token,
  secret_key: "c00d0782995d76ca3dce7584aeb12ae7b6bf0723",
  salt: "18c80dfee980a1b29ce29fdc46f0dd4b11629c04"
