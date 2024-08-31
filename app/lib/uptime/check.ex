defmodule Uptime.Check do
  @moduledoc false
  use Uptime.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          status_code: integer(),
          response_body: binary(),
          dns_time: integer(),
          connect_time: integer(),
          tls_time: integer(),
          first_byte_time: integer(),
          request_time: integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, UXID, autogenerate: true, prefix: "chk"}
  schema "checks" do
    field :status_code, :integer
    field :response_body, :binary
    field :dns_time, :integer
    field :connect_time, :integer
    field :tls_time, :integer
    field :first_byte_time, :integer
    field :request_time, :integer

    belongs_to :service, Uptime.Service

    timestamps()
  end

  def changeset(model \\ %__MODULE__{}, attrs) do
    model
    |> cast(attrs, [
      :status_code,
      :response_body,
      :dns_time,
      :connect_time,
      :tls_time,
      :first_byte_time,
      :request_time
    ])
    |> validate_required([
      :status_code,
      :response_body,
      :dns_time,
      :connect_time,
      :tls_time,
      :first_byte_time,
      :request_time
    ])
    |> put_assoc(:service, attrs.service)
  end
end
