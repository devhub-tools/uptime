import Config

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20

config :phoenix_live_view,
  debug_heex_annotations: true,
  enable_expensive_runtime_checks: true

config :uptime, Uptime.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "uptime_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :uptime, UptimeWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "EJalNO1mvFZZ1P4v3U8nsPomUrhuUYSeuKTsQ9+9fbVF/ROutgvMeCEPpWF47WbI",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:uptime, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:uptime, ~w(--watch)]}
  ]

config :uptime, UptimeWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/uptime_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :uptime,
  dev_routes: true,
  supported_config_dirs: [File.cwd!()],
  supported_secrets_dir: File.cwd!()
