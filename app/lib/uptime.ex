defmodule Uptime do
  @moduledoc """
  Uptime keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

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
end
