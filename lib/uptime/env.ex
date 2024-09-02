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

  @spec get(String.t()) :: String.t()
  def get(name) do
    System.get_env(name)
  end

  @spec get(String.t()) :: String.t()
  def get_secret(name) do
    case File.read("/etc/secrets/#{name}") do
      {:ok, value} -> value
      _ -> get(name)
    end
  end

  @spec has?(String.t()) :: boolean()
  def has?(name) do
    name
    |> get()
    |> valid_env_var_value()
  end

  @spec has_secret?(String.t()) :: boolean()
  def has_secret?(name) do
    case File.read("/etc/secrets/#{name}") do
      {:ok, value} -> valid_env_var_value(value)
      _ -> has?(name)
    end
  end

  @spec valid_env_var_value(String.t()) :: boolean()
  defp valid_env_var_value(value) do
    value != nil and value != ""
  end

  @spec has_basic_auth?() :: boolean()
  def has_basic_auth? do
    Uptime.Env.has?("BASIC_AUTH_USERNAME") and "BASIC_AUTH_PASSWORD" |> Uptime.Env.has_secret?() |> dbg()
  end

  @spec build_version() :: String.t()
  def build_version, do: Application.get_env(:uptime, :build_version)
end
