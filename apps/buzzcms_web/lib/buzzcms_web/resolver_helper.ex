defmodule BuzzcmsWeb.ResolverHelper do
  alias Buzzcms.Repo
  import Ecto.Query
  alias Absinthe.Relay.Connection

  def list(params, schema, filter_definition, opts \\ []) do
    query =
      case Keyword.get(opts, :parse_addition_filter) do
        parse_addition_filter when is_function(parse_addition_filter) ->
          schema |> parse_addition_filter.(params)

        _ ->
          schema
      end
      |> FilterParser.FilterParser.parse(params[:filter], filter_definition)

    {:ok, result} =
      case params do
        %{offset: offset} ->
          {:ok, :forward, limit} = Connection.limit(params)

          query
          |> limit(^limit)
          |> offset(^offset)
          |> order_by(^get_order_by(params))
          |> Repo.all()
          |> Connection.from_slice(offset)

        _ ->
          Absinthe.Relay.Connection.from_query(
            query
            |> order_by(^get_order_by(params)),
            &Repo.all/1,
            params
          )
      end

    count = Repo.aggregate(query, :count)
    {:ok, result |> Map.put(:count, count)}
  end

  defp get_order_by(params) do
    case params do
      %{order_by: order_by} ->
        order_by
        |> Enum.map(fn %{field: field, direction: order_direction} ->
          {order_direction, field}
        end)
        |> Keyword.new()

      _ ->
        []
    end
  end
end
