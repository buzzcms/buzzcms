defmodule BuzzcmsWeb.Schema.Products do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers
  import Ecto.Query

  alias BuzzcmsWeb.Data

  @filter_ids []
  @input_ids []

  node object(:product) do
    field(:available_at, :datetime)
    field(:discontinue_at, :datetime)

    field :master_variant, :variant,
      resolve:
        dataloader(
          Data,
          :master_variant,
          args: %{
            where: fn schema -> schema |> where([p], p.is_master == true) end
          }
        )

    field(:variants, non_null(list_of(non_null(:variant))),
      resolve:
        dataloader(
          Data,
          :variants,
          args: %{
            where: fn schema -> schema |> where([p], p.is_master != true) end
          }
        )
    )

    field(:option_types, non_null(list_of(non_null(:option_type))),
      resolve: dataloader(Data, :option_types)
    )
  end

  connection(node_type: :product) do
    edge do
      field(:node, non_null(:product))
    end
  end

  input_object :product_input do
    field(:available_at, :datetime)
    field(:discontinue_at, :datetime)
  end

  input_object :product_filter_input do
    field(:code, :string_filter_input)
  end

  object :product_queries do
    connection field(:products, node_type: :product) do
      arg(:filter, :product_filter_input)
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&BuzzcmsWeb.ProductResolver.list/2)
    end
  end

  object :product_mutations do
    payload field(:create_product) do
      input do
        field(:data, :product_input)
      end

      output do
        field(:result, :product_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&BuzzcmsWeb.ProductResolver.create/2)
    end

    payload field(:edit_product) do
      input do
        field(:id, :id)
        field(:data, :product_input)
      end

      output do
        field(:result, :product_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&BuzzcmsWeb.ProductResolver.edit/2)
    end

    payload field(:delete_product) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :product_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&BuzzcmsWeb.ProductResolver.delete/2)
    end
  end
end
