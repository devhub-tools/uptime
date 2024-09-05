defmodule Uptime.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Uptime.Env

  @impl true
  def start(_type, _args) do
    :ok = Env.validate_configuration()

    children = [
      UptimeWeb.Telemetry,
      Uptime.Repo,
      {Phoenix.PubSub, name: Uptime.PubSub},
      {Oban, Application.fetch_env!(:uptime, Oban)},
      UptimeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uptime.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UptimeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
