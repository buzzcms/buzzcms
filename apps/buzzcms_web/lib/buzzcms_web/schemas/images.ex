defmodule BuzzcmsWeb.Schema.Images do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.ImageResolver

  @filter_ids []
  @input_ids [id: :image]

  node object(:image) do
    field(:name, non_null(:string))

    field :uid, non_null(:id) do
      resolve(fn _, %{source: source} ->
        {:ok, source.id}
      end)
    end

    field(:remote_url, :string)
    field(:ext, non_null(:string))
    field(:mime, :string)
    field(:width, :decimal)
    field(:height, :decimal)
    field(:size, non_null(:decimal))
    field(:code, non_null(:string))
    field :created_at, :datetime
  end

  input_object :image_filter_input do
    field(:name, :string_filter_input)
    field(:remote_url, :string_filter_input)
  end

  connection(node_type: :image) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:image))
    end
  end

  input_object :image_input do
    field(:name, :string)
  end

  object :image_queries do
    connection field(:images, node_type: :image) do
      arg(:filter, :image_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&ImageResolver.list/2)
    end
  end

  object :image_mutations do
    payload field(:edit_image) do
      input do
        field(:id, :id)
        field(:data, :image_input)
      end

      output do
        field(:result, :image_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&ImageResolver.edit/2)
    end

    payload field(:delete_image) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :image_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&ImageResolver.delete/2)
    end
  end
end
