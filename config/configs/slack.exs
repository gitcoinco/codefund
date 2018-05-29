use Mix.Config

config :code_fund, CodeFundWeb.Endpoint,
  slack_token: System.get_env("SLACK_TOKEN"),
  slack_bot_name: System.get_env("SLACK_BOT_NAME"),
  slack_avatar: System.get_env("SLACK_AVATAR"),
  slack_channel: System.get_env("SLACK_CHANNEL"),
  slack_admin: System.get_env("SLACK_ADMIN")

config :slack, api_token: System.get_env("SLACK_TOKEN")
