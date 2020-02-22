defmodule Buzzcms.Schema.OptionValue do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:option_type_id]
  @optional_fields [:value, :position]

  schema "option_value" do
    field :code, :string
    field :display_name, :string
    belongs_to :option_type, Buzzcms.Schema.OptionType
    field :position, :integer
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code, name: :option_value_option_type_id_code)
  end
end
