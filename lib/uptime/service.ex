defmodule Uptime.Service do
  @moduledoc false
  use Uptime.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
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
    field :method, :string
    field :url, :string
    field :expected_status_code, :string
    field :expected_response_body, :string
    field :interval_ms, :integer, default: 60_000
    field :timeout_ms, :integer, default: 10_000
    field :enabled, :boolean, default: true

    has_many :checks, Uptime.Check, preload_order: [desc: :inserted_at]

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
      :method,
      :url,
      :expected_status_code
    ])
    |> validate_timeout_interval()
  end

  defp validate_timeout_interval(changeset) do
    timeout_ms = get_field(changeset, :timeout_ms)
    interval_ms = get_field(changeset, :interval_ms)

    if timeout_ms >= interval_ms do
      add_error(changeset, :timeout_ms, "must be smaller than interval_ms")
    else
      changeset
    end
  end
end
