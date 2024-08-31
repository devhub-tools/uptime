defmodule Uptime.Checker do
  @moduledoc false
  use GenServer

  def start_link(service) do
    GenServer.start_link(__MODULE__, service, name: {:via, Registry, {Uptime.CheckerRegistry, service.id}})
  end

  def init(service) do
    :timer.send_interval(service.interval_ms, :check)
    {:ok, service}
  end

  def handle_info(:check, service) do
    Uptime.run_check(service)
    {:noreply, service}
  end
end
