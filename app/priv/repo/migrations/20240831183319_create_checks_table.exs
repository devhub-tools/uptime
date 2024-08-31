defmodule Uptime.Repo.Migrations.CreateChecksTable do
  use Ecto.Migration

  def change do
    create table(:checks) do
      add :service_id, references(:services, on_delete: :delete_all), null: false
      add :status_code, :integer
      add :response_body, :binary
      add :dns_time, :integer
      add :connect_time, :integer
      add :tls_time, :integer
      add :first_byte_time, :integer
      add :request_time, :integer

      timestamps()
    end
  end
end
