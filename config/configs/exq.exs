use Mix.Config

config :exq,
  name: Exq,
  host: System.get_env("REDIS_HOST"),
  port: System.get_env("REDIS_PORT"),
  # password: System.get_env("REDIS_PASSWORD"),
  namespace: "exq",
  concurrency: :infinite,
  queues: [
    {"cs_high", 50},
    {"cs_default", 10},
    {"cs_low", 1}
  ],
  poll_timeout: 50,
  scheduler_poll_timeout: 200,
  scheduler_enable: true,
  max_retries: 5,
  shutdown_timeout: 5000

config :exq_ui,
  server: true
