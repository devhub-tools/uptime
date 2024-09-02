defmodule Uptime.Repo.Migrations.ServiceTimeoutSetting do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :timeout_ms, :integer, default: 5000, null: false
      modify :interval_ms, :integer, default: 60000, null: false, from: :integer
    end

    alter table(:checks) do
      add :status, :text, NULL: false, default: "pending"
    end
  end
end
