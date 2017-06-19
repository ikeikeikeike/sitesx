defmodule Sitesx.Support.Site do
  use Ecto.Schema
  # import Ecto
  # import Ecto.Query
  import Ecto.Changeset

  schema "sites" do
    field :name, :string
    field :dns, :boolean

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :dns])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
