import Config

config :esbuild,
  version: "0.17.11",
  uptime: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :tailwind,
  version: "3.4.3",
  uptime: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :uptime, Uptime.Repo,
  migration_primary_key: [type: :text],
  migration_timestamps: [type: :utc_datetime_usec]

config :uptime, UptimeWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: UptimeWeb.ErrorHTML, json: UptimeWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Uptime.PubSub,
  live_view: [signing_salt: "GoHR/4L6"]

config :uptime,
  ecto_repos: [Uptime.Repo],
  generators: [timestamp_type: :utc_datetime_usec, binary_id: true]

import_config "#{config_env()}.exs"
