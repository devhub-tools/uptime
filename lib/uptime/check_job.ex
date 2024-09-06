defmodule Uptime.CheckJob do
  @moduledoc false
  use Oban.Worker,
    unique: [keys: [:id], period: :infinity, states: [:scheduled, :available, :retryable]]

  alias Uptime.Service

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}, scheduled_at: scheduled_at}) do
    started_at = DateTime.utc_now()

    case Uptime.get_service!(id) do
      %Service{enabled: true} = service ->
        {:ok, pid} = Uptime.Tracer.start_link(service)

        case Uptime.Tracer.trace_request(pid) do
          {:ok, result} ->
            Uptime.save_check!(%{
              service_id: service.id,
              status: Service.status(service, result),
              status_code: result.status_code,
              response_body: result.response_body,
              dns_time: result.dns_done,
              connect_time: result.connected,
              tls_time: result.tls_done,
              first_byte_time: result.first_byte,
              request_time: result.complete
            })

          {:error, :timeout} ->
            Uptime.save_check!(%{
              service_id: service.id,
              status: :timeout
            })
        end

        schedule_at = DateTime.add(scheduled_at, service.interval_ms, :millisecond)

        schedule_at =
          if DateTime.before?(schedule_at, started_at) do
            DateTime.add(started_at, service.interval_ms, :millisecond)
          else
            schedule_at
          end

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
