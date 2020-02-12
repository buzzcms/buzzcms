defmodule Buzzcms.Schema.Taxonomy do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:code, :display_name]
  @optional_fields []

  schema "taxonomy" do
    field :code, :string
    field :display_name, :string
    many_to_many :entry_types, Buzzcms.Schema.EntryType, join_through: "entry_type_taxonomy"
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
  end
end
