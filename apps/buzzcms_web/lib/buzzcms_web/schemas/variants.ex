defmodule BuzzcmsWeb.Schema.Variants do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.VariantResolver

  @filter_ids []
  @input_ids []

  node object(:variant) do
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

  connection(node_type: :variant) do
    edge do
      field(:node, non_null(:variant))
    end
  end

  input_object :variant_input do
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

  input_object :variant_filter_input do
    field(:is_master, :boolean_filter_input)
  end

  object :variant_queries do
    connection field(:variants, node_type: :variant) do
      arg(:filter, :variant_filter_input)
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&VariantResolver.list/2)
    end
  end

  object :variant_mutations do
    payload field(:create_variant) do
      input do
        field(:data, :variant_input)
      end

      output do
        field(:result, :variant_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&VariantResolver.create/2)
    end

    payload field(:edit_variant) do
      input do
        field(:id, :id)
        field(:data, :variant_input)
      end

      output do
        field(:result, :variant_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&VariantResolver.edit/2)
    end

    payload field(:delete_variant) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :variant_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&VariantResolver.delete/2)
    end
  end
end
