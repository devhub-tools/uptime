defmodule Uptime.Env do
  @moduledoc """
  Uptime environment configuration.
  """
  require Logger

  @config_env Application.compile_env(:uptime, :env)

  @supported_config_filenames ["config.yaml", "config.yml"]

  @prefix "UPTIME"

  @supported_config_env_vars_suffix [
    "BASIC_AUTH_USERNAME",
    "BASIC_AUTH_PASSWORD"
  ]

  @valid_config_env_vars Enum.map(@supported_config_env_vars_suffix, &"#{@prefix}_#{&1}")

  @secrets_directory Application.compile_env(:uptime, :supported_secrets_dir, "/etc/secrets")

  @spec config_env() :: :prod | :dev | :test
  def config_env, do: @config_env

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

  @spec has?(String.t()) :: boolean()
  def has?(name) do
    name
    |> read()
    |> valid_env_var_value()
  end

  @spec get(atom(), any()) :: any()
  def get(key, default \\ nil), do: Application.get_env(:uptime, key, default)

  @spec read(String.t(), Keyword.t()) :: [map()]
  def read_services do
    read_services_from_env() ++ read_services_from_config_file()
  end

  defp read_services_from_config_file do
    "services"
    |> read_from_config_file()
    |> case do
      {:ok, services} -> services
      _error -> []
    end
    |> Enum.map(fn service ->
      service
      |> Map.new(fn {k, v} -> {String.downcase(k), v} end)
      |> Map.new(fn
        {"expected_status_code" = k, v} when is_integer(v) -> {k, Integer.to_string(v)}
        pair -> pair
      end)
    end)
  end

  defp read_services_from_env do
    System.get_env()
    |> Map.keys()
    |> Enum.filter(&String.starts_with?(String.upcase(&1), "#{@prefix}_SERVICE_"))
    |> Enum.group_by(
      fn var ->
        var
        |> String.split("_")
        |> case do
          [@prefix, "SERVICE", index | _name] -> @prefix <> "_SERVICE_" <> index
          _invalid -> nil
        end
      end,
      fn var ->
        var
        |> String.split("_")
        |> case do
          [@prefix, "SERVICE", _index | name] -> Enum.join(name, "_")
          _invalid -> nil
        end
      end
    )
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn
      {service_prefix, fields} ->
        Map.new(fields, fn field -> {String.downcase(field), System.get_env("#{service_prefix}_#{field}")} end)
    end)
  end

  @type value_type :: :string | :integer | :boolean | :uri | :cors
  @type config_type :: String.t() | integer() | boolean() | URI.t() | [String.t()] | nil | any()

  @doc """
  Read a value from the environment.
  First check for a secrets file, then the environment, then the config file.
  secrets file > environment variable > config file
  """
  @spec read(String.t(), config_type(), any()) :: config_type()
  def read(name, type \\ :string, default \\ nil) do
    prefixed_name = "#{@prefix}_#{name}"

    secret_file_path = Path.join(@secrets_directory, prefixed_name)

    with {:error, _error} <- File.read(secret_file_path),
         :error <- System.fetch_env(prefixed_name),
         :error <- read_from_config_file(name) do
      default
    else
      {:ok, value} ->
        if valid_env_var_value(value) do
          parse_value(value, type)
        else
          default
        end
    end
  end

  @spec read_from_config_file(String.t()) :: any() | nil
  defp read_from_config_file(key) do
    key = String.downcase(key)

    with path when is_binary(path) <- find_config_path(),
         {:ok, config} <- YamlElixir.read_from_file(path),
         true <- Map.has_key?(config, key) do
      {:ok, config[key]}
    else
      _error ->
        :error
    end
  end

  @spec find_config_path() :: String.t() | nil
  defp find_config_path do
    @supported_config_filenames
    |> Enum.reduce([], fn file, acc ->
      Enum.map(get(:supported_config_dirs, ["/etc/uptimes/config.yaml"]), &Path.join(&1, file)) ++ acc
    end)
    |> Enum.find(&File.exists?/1)
  end

  @spec valid_env_var_value(String.t()) :: boolean()
  defp valid_env_var_value(value) do
    value != nil and value != ""
  end

  # Values may be stringified (from env) or the correct type (from config file)
  defp parse_value(value, :string), do: value
  defp parse_value(nil, :integer), do: nil
  defp parse_value(value, :integer) when is_integer(value), do: value
  defp parse_value(value, :integer), do: String.to_integer(value)

  defp parse_value(value, :boolean) when value in [1, true], do: true
  defp parse_value(value, :boolean) when value in [0, false], do: false

  defp parse_value(value, :boolean) do
    cond do
      String.downcase(value) in ~w(true 1) -> true
      String.downcase(value) in ~w(false 0) -> false
      true -> nil
    end
  end

  defp parse_value(nil, :uri), do: nil
  defp parse_value("", :uri), do: nil
  defp parse_value(value, :uri), do: URI.parse(value)

  @spec get_uri_part(URI.t() | any(), :scheme | :host | :port) :: String.t() | nil
  def get_uri_part(%URI{scheme: scheme}, :scheme), do: scheme
  def get_uri_part(%URI{host: host}, :host), do: host
  def get_uri_part(%URI{port: port}, :port), do: port
  def get_uri_part(_invalid, _part), do: nil
end
