defmodule Uptime.Env do
  @moduledoc """
  Uptime environment configuration.
  """
  @spec build_version() :: String.t()
  def build_version, do: Application.get_env(:uptime, :build_version)
end
