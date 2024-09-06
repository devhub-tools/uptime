defmodule Uptime.Service do
  @moduledoc false
  use Uptime.Schema

  import Ecto.Changeset

  alias Uptime.Check
  alias Uptime.Tracer.Result

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          slug: String.t(),
          method: String.t(),
          url: String.t(),
          expected_status_code: String.t(),
          expected_response_body: String.t(),
          interval_ms: integer(),
          timeout_ms: integer(),
          checks: [Uptime.Check.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, UXID, autogenerate: true, prefix: "svc"}
  schema "services" do
    field :name, :string
    field :slug, :string
    field :method, :string, default: "GET"
    field :url, :string
    # expected status code is a string as it can also be a pattern like "2xx"
    # TODO: we should make this a list
    field :expected_status_code, :string
    # TODO: we should make this a list
    field :expected_response_body, :string
    field :interval_ms, :integer, default: 60_000
    field :timeout_ms, :integer, default: 10_000
    field :enabled, :boolean, default: true

    has_many :checks, Check, preload_order: [desc: :inserted_at]

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [
      :name,
      :method,
      :url,
      :expected_status_code,
      :expected_response_body,
      :interval_ms,
      :timeout_ms,
      :enabled
    ])
    |> validate_required([
      :name,
      :url,
      :expected_status_code
    ])
    |> unique_constraint(:name)
    |> validate_timeout_interval()
    |> put_slug()
    |> unique_constraint(:slug)
  end

  defp validate_timeout_interval(%Ecto.Changeset{} = changeset) do
    timeout_ms = get_field(changeset, :timeout_ms)
    interval_ms = get_field(changeset, :interval_ms)

    if timeout_ms >= interval_ms do
      add_error(changeset, :timeout_ms, "must be smaller than interval_ms")
    else
      changeset
    end
  end

  defp put_slug(%Ecto.Changeset{} = changeset) do
    changeset
    |> get_change(:name, "")
    |> String.downcase()
    # Only support alphanumeric characters and dashes in slugs
    |> String.replace(~r/[^a-z0-9\- ]/, "")
    |> String.split(" ")
    |> Enum.filter(&(&1 && &1 != ""))
    |> Enum.join("-")
    # Remove any sequential dashes
    |> String.split("-")
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("-")
    |> then(&put_change(changeset, :slug, &1))
  end

  # TODO: logic is WIP
  @spec status(__MODULE__.t(), Result.t()) :: Check.status()
  def status(%__MODULE__{} = service, %Result{} = result) do
    result =
      with :error <- Integer.parse(service.expected_status_code),
           :error <- regex?(service.expected_response_body, result.response_body),
           true <- service.expected_response_body == "" do
        :failure
      else
        {code, _str} when is_integer(code) ->
          status_code?(code, service.expected_status_code, result)

        {:ok, result} when is_boolean(result) ->
          result

        false ->
          response_body?(service.expected_response_body, result.response_body)
      end

    if result do
      :success
    else
      :failure
    end
  end

  @spec status_code?(integer(), String.t(), Result.t()) :: boolean()
  defp status_code?(code, code_str, %Result{} = result) do
    code_length = code |> Integer.digits() |> length()

    cond do
      code_length == 3 ->
        code == result.status_code

      code_length == 1 and
          String.starts_with?(code_str, Integer.to_string(code)) ->
        String.starts_with?(Integer.to_string(result.status_code), Integer.to_string(code))

      true ->
        false
    end
  end

  @spec regex?(String.t(), String.t()) :: boolean()
  defp regex?(expected, value) do
    case Regex.compile(expected) do
      {:ok, regex} ->
        {:ok, Regex.match?(regex, value)}

      {:error, _} ->
        :error
    end
  end

  @spec response_body?(String.t(), String.t()) :: boolean()
  defp response_body?(expected, value) do
    String.contains?(value, expected)
  end
end
