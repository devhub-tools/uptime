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

  def validate_config_env_vars do
    System.get_env()
    |> Map.keys()
    |> Enum.filter(&String.starts_with?(String.upcase(&1), @prefix))
    |> Enum.each(fn var ->
      unless Enum.member?(@valid_config_env_vars, var) do
        Logger.warning("Invalid environment variable: #{var}")
      end
    end)
  end

  def get(@prefix <> suffix) do
    System.get_env("#{@prefix}_#{suffix}")
  end

  def get(suffix) do
    System.get_env("#{@prefix}_#{suffix}")
  end

  def has?(name) do
    name
    |> get()
    |> then(&(&1 != nil and &1 != ""))
  end

  @spec has_basic_auth?() :: boolean()
  def has_basic_auth? do
    Uptime.Env.has?("BASIC_AUTH_USERNAME") and Uptime.Env.has?("BASIC_AUTH_PASSWORD")
  end

  @spec build_version() :: String.t()
  def build_version, do: Application.get_env(:uptime, :build_version)
end
