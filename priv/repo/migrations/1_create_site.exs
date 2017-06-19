defmodule Sitesx.Support.Migrations.CreateSite do
  use Ecto.Migration

  def change do
    create table(:sites) do
      add :name, :string
      add :dns, :boolean, default: false

      timestamps()
    end
    create index(:sites, [:name], unique: true)
    create index(:sites, [:dns])

  end
end
