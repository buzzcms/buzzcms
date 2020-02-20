defmodule Buzzcms.Schema.Product do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:entry_id, :available_at, :discontinue_at]
  @optional_fields []

  schema "product" do
    belongs_to :entry, Buzzcms.Schema.Entry
    has_many :variants, Buzzcms.Schema.Variant
    has_many :option_types, Buzzcms.Schema.OptionType
    field :available_at, :utc_datetime
    field :discontinue_at, :utc_datetime
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
