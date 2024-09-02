defmodule Uptime.CheckJob do
  @moduledoc false
  use Oban.Worker, unique: [keys: [:id], period: :infinity, states: [:scheduled, :available, :retryable]]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}, scheduled_at: scheduled_at}) do
    case Uptime.get_service(id) do
      %{enabled: true} = service ->
        {:ok, pid} = Uptime.Tracer.start_link(service)

        {:ok, result} = GenServer.call(pid, :trace_request)

        Uptime.save_check(service, result)

        schedule_at = DateTime.add(scheduled_at, service.interval_ms, :millisecond)

        {:ok, _job} =
          %{id: id}
          |> Uptime.CheckJob.new(scheduled_at: schedule_at)
          |> Oban.insert()

        :ok

      _service ->
        :ok
    end

    :ok
  end
end
