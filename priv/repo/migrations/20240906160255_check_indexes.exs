defmodule Uptime.Repo.Migrations.CheckIndexes do
  use Ecto.Migration

  def change do
    create index(:checks, [:service_id])
    create index(:checks, [:inserted_at])
  end
end
