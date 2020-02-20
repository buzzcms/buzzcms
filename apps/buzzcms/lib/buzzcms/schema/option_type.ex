defmodule Buzzcms.Schema.OptionType do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:product_id]
  @optional_fields [:name, :position]

  schema "option_type" do
    belongs_to :product, Buzzcms.Schema.Product
    has_many :option_values, Buzzcms.Schema.OptionValue
    field :name, :string
    field :position, :integer
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
