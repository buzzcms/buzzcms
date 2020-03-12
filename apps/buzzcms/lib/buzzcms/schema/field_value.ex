defmodule Buzzcms.Schema.FieldValue do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:field_id, :code, :display_name, :position]
  @optional_fields [:position, :description]

  schema "field_value" do
    field :code, :string
    field :display_name, :string
    field :description, :string, default: ""
    field :position, :integer, default: 0
    belongs_to :field, Buzzcms.Schema.Field
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code, name: :field_value_field_id_code)
  end
end
