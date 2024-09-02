defmodule Uptime.Repo.Migrations.ServiceEnabled do
  use Ecto.Migration

  def change do
    alter table(:services) do
      add :enabled, :boolean, default: true, null: false
    end
  end
end
