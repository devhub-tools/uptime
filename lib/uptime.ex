defmodule Uptime do
  @moduledoc false
  @callback save_check(Uptime.Service.t()) :: Uptime.Check.t()
  def save_check(service, result) do
    %{
      service: service,
      status_code: result.status_code,
      response_body: result.response_body,
      dns_time: result.dns_done,
      connect_time: result.connected,
      tls_time: result.tls_done,
      first_byte_time: result.first_byte,
      request_time: result.complete
    }
    |> Uptime.Check.changeset()
    |> Uptime.Repo.insert!()
  end

  def get_service(id) do
    Uptime.Repo.get(Uptime.Service, id)
  end
end
