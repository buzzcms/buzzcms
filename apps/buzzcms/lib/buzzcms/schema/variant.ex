defmodule Buzzcms.Schema.Variant do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields [:product_id]
  @optional_fields [
    :sku,
    :key,
    :is_master,
    :image,
    :position,
    :list_price,
    :sale_price,
    :weight,
    :height,
    :width,
    :depth,
    :track_inventory,
    :is_valid
  ]

  schema "variant" do
    belongs_to :product, Buzzcms.Schema.Product
    field :sku, :string
    field :key, :string
    field :is_master, :boolean
    field :image, :string
    field :position, :integer
    field :list_price, :decimal
    field :sale_price, :decimal
    field :weight, :decimal
    field :height, :decimal
    field :width, :decimal
    field :depth, :decimal
    field :track_inventory, :boolean
    field :is_valid, :boolean
  end

  def changeset(entity, params \\ %{}) do
    entity
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end
