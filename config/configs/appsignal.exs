use Mix.Config

config :appsignal, :config,
  active: true,
  name: System.get_env("APPSIGNAL_APP_NAME") || "CodeFund",
  push_api_key: System.get_env("APPSIGNAL_PUSH_API_KEY") || "your-push-api-key",
  env: System.get_env("APPSIGNAL_APP_ENV") || Mix.env(),
  filter_parameters: ["password", "secret"]
