defmodule Uptime.Env do
  @moduledoc """
  Uptime environment configuration.
  """
  @spec build_version() :: String.t()
  def build_version, do: Application.get_env(:uptime, :build_version)

  @spec request_tracer_connection() :: String.t()
  def request_tracer_connection do
    host = System.get_env("REQUEST_TRACER_HOST") || "localhost"
    port = String.to_integer(System.get_env("REQUEST_TRACER_PORT") || "50051")
    "#{host}:#{port}"
  end
end
