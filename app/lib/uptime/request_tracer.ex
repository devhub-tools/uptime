defmodule Uptime.RequestTracer do
  alias Uptime.RequestTracer.Client

  def run_check(_method, url) do
    GenServer.call(Client, {:check, url})
  end
end
