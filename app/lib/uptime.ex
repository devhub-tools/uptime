defmodule Uptime do
  @moduledoc false
  @callback run_check(Uptime.Service.t()) :: Uptime.Check.t()
  def run_check(service) do
    %DevhubProtos.Uptime.V1.CheckResponse{} =
      response = Uptime.RequestTracer.run_check(service.method, service.url)

    %{
      service: service,
      status_code: response.status_code,
      response_body: response.response_body,
      dns_time: response.dns,
      connect_time: response.connect,
      tls_time: response.tls,
      first_byte_time: response.first_byte,
      request_time: response.complete
    }
    |> Uptime.Check.changeset()
    |> Uptime.Repo.insert!()
  end

  def get_service(id) do
    Uptime.Repo.get(Uptime.Service, id)
  end
end
