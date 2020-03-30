defmodule Buzzcms.Schema.OptionType do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:product_id]
  @optional_fields [:name, :position]

  schema "option_type" do
    field :code, :string
    field :display_name, :string
    belongs_to :product, Buzzcms.Schema.Product
    has_many :option_values, Buzzcms.Schema.OptionValue
    field :position, :integer
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:code, name: :option_type_product_id_code)
    |> foreign_key_constraint(:product_id)
  end
end
