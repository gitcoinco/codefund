defmodule CodeFund.Mixfile do
  use Mix.Project

  def project do
    [
      app: :code_fund,
      version: "0.0.1",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {CodeFund.Application, []},
      extra_applications: [
        :ex_machina,
        :logger,
        :runtime_tools,
        :coherence,
        :geolix,
        :exq,
        :exq_ui,
        :geoip,
        :redix,
        :scrivener_ecto,
        :scrivener_html,
        :timex,
        :timex_ecto,
        :sentry,
        :corsica,
        :bamboo,
        :phoenix_html_simplified_helpers
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencieas.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 0.9.0", only: [:dev, :test], runtime: false},
      # {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:dialyxir,
       github: "asummers/dialyxir",
       branch: "elixir-formatter",
       runtime: false,
       only: [:dev, :test]},
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:ex_money, "~> 1.0"},
      {:number, "~> 0.5.4"},
      {:coherence,
       github: "smpallen99/coherence", sha: "96607cefb1b6269c6e8dea6fab897ed9489ad749"},
      {:ex_machina, "~> 2.1"},
      {:browser, "~> 0.1.0"},
      {:csv, "~> 2.0.0"},
      {:exq, "~> 0.10.1"},
      {:ex_aws, "~> 2.0"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.9"},
      {:exq_ui, "~> 0.9.0"},
      {:geoip, "~> 0.1"},
      {:geolix, "~> 0.16"},
      {:staccato,
       github: "StareIntoTheBeard/staccato-ex", branch: "fix_a_bunch_of_random_things"},
      {:httpoison, "~> 1.0", override: true},
      {:phoenix_active_link, "~> 0.1.1"},
      {:scrivener, "~> 2.0"},
      {:scrivener_ecto, "~> 1.0"},
      {:scrivener_html, "~> 1.7"},
      {:slack, "~> 0.13.0"},
      {:redix, ">= 0.5.0"},
      {:filtrex, "~> 0.4.1"},
      {:inflex, "~> 1.10.0"},
      {:timex, "~> 3.1"},
      {:timex_ecto, "~> 3.0"},
      {:remote_ip, "~> 0.1.0"},
      {:sentry, "~> 6.4"},
      {:corsica, "~> 1.0"},
      {:joken, "~> 1.5.0"},
      {:bamboo, "~> 0.8"},
      {:phoenix_html_simplified_helpers, "~> 2.0.1"},
      {:mock, "~> 0.3.0", only: :test},
      {:excoveralls, "~> 0.8", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "code_fund.seed"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
