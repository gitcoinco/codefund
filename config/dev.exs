use Mix.Config

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
  metabase_site_url: System.get_env("METABASE_SITE_URL"),
  metabase_secret_key: System.get_env("METABASE_SECRET_KEY"),
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
  pool_size: 10

config :code_fund, CodeFund.Mailer, adapter: Bamboo.LocalAdapter

config :redix, database: 1

# Uncomment when developing locally
# import_config "dev.secret.exs"
