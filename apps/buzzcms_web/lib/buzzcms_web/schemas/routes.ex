defmodule BuzzcmsWeb.Schema.Routes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.RouteResolver

  @filter_ids []
  @input_ids [id: :route]

  node object(:route) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field(:name, non_null(:string))
    field(:pattern, non_null(:string))
    field(:heading, non_null(:json))
    field(:data, non_null(:json))
    field(:seo, non_null(:json))
  end

  enum :route_order_field do
    value(:name)
  end

  input_object :route_order_by_input do
    field(:field, non_null(:route_order_field))
    field(:direction, non_null(:order_direction))
  end

  input_object :route_filter_input do
    field(:name, :string_filter_input)
  end

  connection(node_type: :route) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:route))
    end
  end

  input_object :route_input do
    field(:name, :string)
    field(:pattern, :string)
    field(:heading, :json)
    field(:data, :json)
    field(:seo, :json)
  end

  object :route_queries do
    connection field(:routes, node_type: :route) do
      arg(:filter, :route_filter_input)
      arg(:order_by, list_of(non_null(:route_order_by_input)))
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&RouteResolver.list/2)
    end
  end

  object :route_mutations do
    payload field(:create_route) do
      input do
        field(:data, :route_input)
      end

      output do
        field(:result, :route_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&RouteResolver.create/2)
    end

    payload field(:edit_route) do
      input do
        field(:id, :id)
        field(:data, :route_input)
      end

      output do
        field(:result, :route_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&RouteResolver.edit/2)
    end

    payload field(:delete_route) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :route_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&RouteResolver.delete/2)
    end
  end
end
