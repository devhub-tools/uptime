defmodule Uptime.Service do
  use Uptime.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          method: String.t(),
          url: String.t(),
          expected_status_code: String.t(),
          expected_response_body: String.t(),
          interval: String.t(),
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
    field :interval, :string

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
      :interval
    ])
    |> validate_required([
      :name,
      :method,
      :url,
      :expected_status_code,
      :expected_response_body,
      :interval
    ])
  end
end
