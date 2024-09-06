defmodule Uptime.Repo.Migrations.ServiceIndexes do
  use Ecto.Migration

  def change do
    create_if_not_exists unique_index(:services, [:name])
    create_if_not_exists unique_index(:services, [:slug])
  end
end
