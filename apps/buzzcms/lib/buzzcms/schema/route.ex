defmodule Buzzcms.Schema.Route do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:name, :pattern]
  @optional_fields [:data]

  schema "route" do
    field :name, :string
    field :pattern, :string
    embeds_one :heading, Buzzcms.EmbeddedSchema.Heading, on_replace: :update
    embeds_one :seo, Buzzcms.EmbeddedSchema.Seo, on_replace: :update
    field :data, :map, default: %{}
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> cast_embed(:seo)
    |> cast_embed(:heading)
    |> validate_required(@required_fields)
    |> unique_constraint(:name)
  end
end
