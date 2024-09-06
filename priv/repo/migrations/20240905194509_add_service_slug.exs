defmodule Uptime.Repo.Migrations.AddServiceSlug do
  use Ecto.Migration

  def change do
    alter table(:services) do
      modify :name, :text, null: false
      add :slug, :text, null: false
    end

    create unique_index(:services, [:name])
    create unique_index(:services, [:slug])
  end
end
