use Mix.Config

config :code_fund, CodeFundWeb.Endpoint, chatlio_widget_id: System.get_env("CHATLIO_WIDGET_ID")
