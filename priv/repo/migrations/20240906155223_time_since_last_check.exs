defmodule Uptime.Repo.Migrations.TimeSinceLastCheck do
  use Ecto.Migration

  def change do
    alter table(:checks) do
      add :time_since_last_check, :integer
    end

    execute("UPDATE checks SET time_since_last_check = 10;", "")

    alter table(:checks) do
      modify :time_since_last_check, :integer, null: false, from: :integer
    end
  end
end
