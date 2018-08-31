use Mix.Config
require Logger

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :code_fund, CodeFundWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [npm: ["start", cd: Path.expand("../assets", __DIR__)]],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/code_fund_web/views/.*(ex)$},
      ~r{lib/code_fund_web/templates/.*(eex)$},
      ~r{lib/code_fund_web/forms/.*(ex)$},
      ~r{lib/code_fund_web/plugs/.*(ex)$}
    ]
  ],
  ga_tracking_id: System.get_env("GA_TRACKING_ID"),
  iubenda_api_key: System.get_env("IUBENDA_API_KEY")

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :code_fund, CodeFund.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("POSTGRES_USER") || "postgres",
  password: System.get_env("POSTGRES_PASSWORD") || "postgres",
  hostname: System.get_env("POSTGRES_HOST") || "localhost",
  database: "code_fund_dev",
  pool_size: 10,
  loggers: [Appsignal.Ecto, Ecto.LogEntry]

config :code_fund, CodeFund.Mailer, adapter: Bamboo.LocalAdapter

config :redix, database: 0

config :time_machinex, TimeMachinex, adapter: TimeMachinex.SystemClock

config :ex_aws,
  region: System.get_env("S3_REGION") || "fakes3",
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID") || "123",
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY") || "asdf",
  bucket: System.get_env("S3_BUCKET") || "stub"

case System.get_env("AWS_ACCESS_KEY_ID") == nil do
  true ->
    Logger.warn(
      "You must start FakeS3 service or set AWS keys in order for file uploads to work properly."
    )

    config :ex_aws, :s3,
      scheme: "http://",
      host: "localhost",
      port: 4567

  false ->
    []
end

# Uncomment when developing locally
# import_config "dev.secret.exs"
