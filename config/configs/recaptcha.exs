use Mix.Config

config :recaptcha,
  public_key: System.get_env("RECAPTCHA_PUBLIC_KEY") || "",
  secret: System.get_env("RECAPTCHA_PRIVATE_KEY") || ""
