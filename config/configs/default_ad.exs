use Mix.Config

config :code_fund, CodeFundWeb.Endpoint,
  default_ad_headline: System.get_env("DEFAULT_AD_HEADLINE"),
  default_ad_body: System.get_env("DEFAULT_AD_BODY"),
  default_ad_image_url: System.get_env("DEFAULT_AD_IMAGE_URL"),
  default_ad_link: System.get_env("DEFAULT_AD_LINK")
