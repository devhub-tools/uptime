defmodule Uptime.Env do
  @moduledoc """
  Uptime environment configuration.
  """
  require Logger

  @prefix "UPTIME"

  @supported_config_env_vars_suffix [
    "BASIC_AUTH_USERNAME",
    "BASIC_AUTH_PASSWORD"
  ]

  @valid_config_env_vars Enum.map(@supported_config_env_vars_suffix, &"#{@prefix}_#{&1}")

  @spec validate_config_env_vars() :: :ok
  def validate_config_env_vars do
    System.get_env()
    |> Map.keys()
    |> Enum.filter(&String.starts_with?(String.upcase(&1), @prefix))
    |> Enum.each(fn var ->
      unless Enum.member?(@valid_config_env_vars, var) do
        Logger.warning("Invalid environment variable: #{var}")
      end
    end)

    :ok
  end

  @spec read(String.t()) :: String.t()
  def read(name) do
    case File.read("/etc/secrets/#{name}") do
      {:ok, value} -> value
      _not_found -> System.get_env(name)
    end
  end

  @spec has?(String.t()) :: boolean()
  def has?(name) do
    name
    |> read()
    |> valid_env_var_value()
  end

  @spec get(atom()) :: any()
  def get(key), do: Application.get_env(:uptime, key)

  @spec valid_env_var_value(String.t()) :: boolean()
  defp valid_env_var_value(value) do
    value != nil and value != ""
  end
end
