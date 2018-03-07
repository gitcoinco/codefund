use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :code_sponsor, CodeSponsorWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :code_sponsor, CodeSponsor.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DATA_DB_USER"),
  password: System.get_env("DATA_DB_PASS"),
  hostname: System.get_env("DATA_DB_HOST"),
  database: "gonano",
  pool: Ecto.Adapters.SQL.Sandbox

import_config "test.secret.exs"
