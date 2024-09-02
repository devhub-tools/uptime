defmodule Uptime.Factory do
  @moduledoc false
  use ExMachina.Ecto, repo: Uptime.Repo

  def service_factory do
    %Uptime.Service{
      id: UXID.generate!(prefix: "svc"),
      name: "Example Service",
      method: "GET",
      url: "https://example.com",
      enabled: true,
      expected_status_code: "200",
      expected_response_body: "ok",
      interval_ms: 60_000,
      timeout_ms: 10_000,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end

  def check_factory do
    %Uptime.Check{
      id: UXID.generate!(prefix: "chk"),
      status: :success,
      status_code: 200,
      response_body: "ok",
      dns_time: 10,
      connect_time: 20,
      tls_time: 30,
      first_byte_time: 40,
      request_time: 100,
      inserted_at: DateTime.utc_now(),
      updated_at: DateTime.utc_now()
    }
  end
end
