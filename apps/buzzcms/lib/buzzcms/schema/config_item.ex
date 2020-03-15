defmodule Buzzcms.Schema.ConfigItem do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:code, :display_name, :type]
  @optional_fields [:note, :data]

  schema "config_item" do
    field :code, :string
    field :display_name, :string
    field :type, FieldTypeEnum
    field :note, :string
    field :data, :map
    field :created_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code)
  end
end
