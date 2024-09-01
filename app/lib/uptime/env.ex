defmodule Uptime.Env do
  @moduledoc """
  Uptime environment configuration.
  """

  @spec deploy_context() :: atom
  def deploy_context, do: Application.get_env(:uptime, :deploy_context)

  @spec prod_context?() :: boolean()
  def prod_context?, do: deploy_context() == :prod

  @spec dev_context?() :: boolean()
  def dev_context?, do: deploy_context() == :dev

  @spec build_version() :: String.t()
  def build_version, do: Application.get_env(:uptime, :build_version)

  @spec request_tracer_connection() :: String.t()
  def request_tracer_connection do
    host = System.get_env("REQUEST_TRACER_HOST") || "localhost"
    port = String.to_integer(System.get_env("REQUEST_TRACER_PORT") || "50051")
    "#{host}:#{port}"
  end
end
