defmodule Uptime.RequestTracer.Client do
  @moduledoc false
  use GenServer

  alias DevhubProtos.Uptime.V1

  def start_link(default) when is_list(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, channel} = GRPC.Stub.connect("localhost:50051")
    {:ok, %{channel: channel}}
  end

  @impl true
  def handle_call({:check, url}, _from, %{channel: channel} = state) do
    request = %V1.CheckRequest{url: url, method: "GET"}

    case V1.UptimeService.Stub.check(channel, request) do
      {:ok, result} -> {:reply, result, state}
      {:error, error} -> {:reply, {:error, error}, state}
    end
  end
end
