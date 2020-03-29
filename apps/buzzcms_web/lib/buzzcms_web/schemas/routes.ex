defmodule BuzzcmsWeb.Schema.Routes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias BuzzcmsWeb.RouteResolver

  node object(:route) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :name, non_null(:string)
    field :pattern, non_null(:string)
    field :heading, :heading
    field :seo, :seo
    field :data, :json
  end

  input_object :route_filter_input do
    field :name, :string_filter_input
  end

  connection(node_type: :route) do
    field :count, non_null(:integer)

    edge do
      field :node, non_null(:route)
    end
  end

  input_object :route_input do
    field :name, :string
    field :pattern, :string
    field :heading, :heading_input
    field :seo, :seo_input
    field :data, :json
  end

  input_object :create_route_data_input do
    field :name, non_null(:string)
    field :pattern, non_null(:string)
    field :heading, :heading_input
    field :seo, :seo_input
    field :data, :json
  end

  object :route_queries do
    connection field :routes, node_type: :route do
      arg(:filter, :route_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      resolve(&RouteResolver.list/2)
    end
  end

  object :route_mutations do
    payload field :create_route do
      input do
        field :data, :create_route_data_input
      end

      output do
        field :result, :route_edge
      end

      resolve(&RouteResolver.create/2)
    end

    payload field :edit_route do
      input do
        field :id, non_null(:id)
        field :data, :route_input
      end

      output do
        field :result, :route_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :route)
      resolve(&RouteResolver.edit/2)
    end

    payload field :delete_route do
      input do
        field :id, non_null(:id)
      end

      output do
        field :result, :route_edge
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :route)
      resolve(&RouteResolver.delete/2)
    end
  end
end
