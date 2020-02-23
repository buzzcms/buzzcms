defmodule Buzzcms.Schema.EntryType do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:code, :display_name]
  @optional_fields []

  schema "entry_type" do
    field :code, :string
    field :display_name, :string
    field :is_product, :boolean
    many_to_many :taxonomies, Buzzcms.Schema.Taxonomy, join_through: "entry_type_taxonomy"
    many_to_many :fields, Buzzcms.Schema.Field, join_through: "entry_type_field"
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
  end
end
