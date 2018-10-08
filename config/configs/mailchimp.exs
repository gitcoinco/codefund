use Mix.Config

config :mailchimp,
  api_key: System.get_env("MAILCHIMP_API_KEY"),
  newsletter_list_id: System.get_env("MAILCHIMP_NEWSLETTER_LIST_ID")
