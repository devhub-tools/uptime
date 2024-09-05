defmodule Uptime.Env do
  @moduledoc """
  Uptime environment configuration.
  """
  require Logger

  @supported_config_filenames ["config.yaml", "config.yml"]

  @prefix "UPTIME"

  @supported_config_env_vars_suffix [
    "BASIC_AUTH_USERNAME",
    "BASIC_AUTH_PASSWORD"
  ]

  @valid_config_env_vars Enum.map(@supported_config_env_vars_suffix, &"#{@prefix}_#{&1}")

  @secrets_directory Application.compile_env(:uptime, :supported_secrets_dir, "/etc/secrets")

  @spec validate_configuration() :: :ok
  def validate_configuration do
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

  @doc """
  Read a value from the environment.
  First check for a secrets file, then the environment, then the config file.
  secrets file > environment variable > config file
  """
  @spec read(String.t(), any()) :: String.t()
  def read(name, default \\ nil) do
    prefixed_name = "#{@prefix}_#{name}"

    secret_file_path = Path.join(@secrets_directory, prefixed_name)

    with {:error, _error} <- File.read(secret_file_path),
         :error <- read_from_env(prefixed_name),
         :error <-
           read_from_config_file(name, find_config_path()) do
      default
    else
      {:ok, value} ->
        if valid_env_var_value(value) do
          value
        else
          default
        end
    end
  end

  @spec read_from_env(String.t()) :: {:ok, String.t()} | :error
  defp read_from_env(name) do
    value = System.get_env(name)

    if valid_env_var_value(value) do
      {:ok, value}
    else
      :error
    end
  end

  @spec read_from_config_file(String.t(), String.t()) :: any() | nil
  defp read_from_config_file(key, path) when is_binary(path) do
    key = String.downcase(key)

    case YamlElixir.read_from_file(path) do
      {:ok, config} ->
        # TODO: Implement a deep get function when we add nested configuration structure
        {:ok, config[key]}

      _not_found ->
        :error
    end
  end

  defp read_from_config_file(_key, nil), do: :error

  @spec find_config_path() :: String.t() | nil
  defp find_config_path do
    @supported_config_filenames
    |> Enum.reduce([], fn file, acc ->
      acc ++
        Enum.map(get(:supported_config_dirs, ["/etc/uptimes/config.yaml"]), &Path.join(&1, file))
    end)
    |> Enum.find(&File.exists?/1)
  end

  @spec has?(String.t()) :: boolean()
  def has?(name) do
    name
    |> read()
    |> valid_env_var_value()
  end

  @spec get(atom(), any()) :: any()
  def get(key, default \\ nil), do: Application.get_env(:uptime, key, default)

  @spec valid_env_var_value(String.t()) :: boolean()
  defp valid_env_var_value(value) do
    value != nil and value != ""
  end
end
