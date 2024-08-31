defmodule Uptime.Repo.Migrations.CreateServicesTable do
  use Ecto.Migration

  def change do
    create table(:services) do
      add :name, :text
      add :method, :text
      add :url, :text
      add :expected_status_code, :text
      add :expected_response_body, :text
      add :interval, :text

      timestamps()
    end
  end
end
