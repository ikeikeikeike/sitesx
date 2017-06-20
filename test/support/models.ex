defmodule Sitesx.Support.Site do
  use Ecto.Schema
  # import Ecto
  # import Ecto.Query
  import Ecto.Changeset

  schema "sites" do
    has_many :entries, Sitesx.Support.Entry
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

defmodule Sitesx.Support.Entry do
  use Ecto.Schema
  # import Ecto
  # import Ecto.Query
  import Ecto.Changeset

  schema "entries" do
    belongs_to :site, Sitesx.Support.Site
    field :title, :string
    field :content, :string

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :content])
  end
end
