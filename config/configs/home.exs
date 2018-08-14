use Mix.Config

config :code_fund, CodeFundWeb.Endpoint,
  home_headline_title: System.get_env("HOME_HEADLINE_TITLE"),
  home_headline_link: System.get_env("HOME_HEADLINE_LINK")
