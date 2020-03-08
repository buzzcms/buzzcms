defmodule Buzzcms.Schema.Route do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:name, :pattern]
  @optional_fields [:heading, :seo, :data]

  schema "route" do
    field :name, :string
    field :pattern, :string
    field :heading, :map, default: %{}
    field :seo, :map, default: %{}
    field :data, :map, default: %{}
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
