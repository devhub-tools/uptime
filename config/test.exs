import Config

config :injexor, default: Mock

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :uptime, Oban, testing: :inline

config :uptime, Uptime.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "uptime_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :uptime, UptimeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "nsevTQJH15ibNcReDj/4EGRMUCapJSpGR3YU28ahYup0K6e09au1vkabv7lZQSAs",
  server: false

config :uptime,
  supported_secrets_dir: Path.join(File.cwd!(), "test")
