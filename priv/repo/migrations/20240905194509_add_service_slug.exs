defmodule Uptime.Repo.Migrations.AddServiceSlug do
  use Ecto.Migration

  def change do
    alter table(:services) do
      modify :name, :text, null: false, from: :text
      add :slug, :text, null: false
    end
  end
end
