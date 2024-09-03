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
  @spec read(String.t()) :: String.t()
  def read(name) do
    prefixed_name = "#{@prefix}_#{name}"

    file_contents =
      :supported_secrets_dir
      |> get("/etc/secrets")
      |> Path.join(prefixed_name)
      |> File.read()

    case file_contents do
      {:ok, value} ->
        value

      _not_found ->
        case read_from_env(prefixed_name) do
          {:ok, value} ->
            value

          _not_found ->
            name
            |> String.downcase()
            |> read_from_config_file(find_config_path())
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
    case YamlElixir.read_from_file(path) do
      {:ok, config} ->
        # TODO: Implement a deep get function when we add nested configuration structure
        config[key]

      _not_found ->
        nil
    end
  end

  defp read_from_config_file(_key, path) when is_nil(path), do: nil

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
