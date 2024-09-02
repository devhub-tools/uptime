defmodule Uptime.CheckJob do
  @moduledoc false
  use Oban.Worker, unique: [keys: [:id], period: :infinity, states: [:scheduled, :available, :retryable]]

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}, scheduled_at: scheduled_at}) do
    case Uptime.get_service!(id) do
      %{enabled: true} = service ->
        {:ok, pid} = Uptime.Tracer.start_link(service)

        case Uptime.Tracer.trace_request(pid) do
          {:ok, result} ->
            Uptime.save_check!(%{
              service_id: service.id,
              # TODO: determine if the check was successful
              status: :success,
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
