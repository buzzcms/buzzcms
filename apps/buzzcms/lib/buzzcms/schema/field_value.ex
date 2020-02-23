defmodule Buzzcms.Schema.FieldValue do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:field_type_id]
  @optional_fields [:value, :position]

  schema "field_value" do
    field :code, :string
    field :display_name, :string
    belongs_to :field, Buzzcms.Schema.Field
    field :position, :integer
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code, name: :field_value_field_id_code)
  end
end
