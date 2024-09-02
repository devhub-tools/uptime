defmodule Uptime.Repo do
  use Ecto.Repo,
    otp_app: :uptime,
    adapter: Ecto.Adapters.Postgres
end
