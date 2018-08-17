use Mix.Config

config :code_fund, AdService.Tracking.AnalyticsManager,
  google_analytics_property_id: System.get_env("GOOGLE_ANALYTICS_IMPRESSION_PROPERTY_ID")
