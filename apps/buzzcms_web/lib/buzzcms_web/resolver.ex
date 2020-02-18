defmodule BuzzcmsWeb.Resolver do
  defmacro __using__(_opts) do
    quote do
      alias Buzzcms.Repo
      import Ecto.Query

      def list(params, %{context: _} = _info) do
        where = get_filter(params)
        order_by = get_order_by(params)

        query =
          @schema
          |> join(:inner, [e], et in Buzzcms.Schema.EntryTaxon, on: e.id == et.entry_id)
          |> where([e, et], et.taxon_id == 70)
          |> where(^where)
          |> order_by(^order_by)

        {:ok, result} = Absinthe.Relay.Connection.from_query(query, &Repo.all/1, params)
        count = Repo.aggregate(query, :count)
        {:ok, result |> Map.put(:count, count)}
      end

      def count(params, %{context: _} = _info) do
        # TODO: Fix me
        where = get_filter(params)
        query = from(@schema, where: ^where)
        Repo.aggregate(query, :count)
      end

      def create(%{data: data}, %{context: _} = _info) do
        input = data

        result =
          %@schema{}
          |> @schema.changeset(input)
          |> Repo.insert()

        case result do
          {:ok, result} -> {:ok, %{result: %{node: Repo.get(@schema, result.id)}}}
          {:error, message} -> {:error, message}
        end
      end

      def edit(%{id: id, data: data}, %{context: _}) do
        result = Repo.get!(@schema, id) |> @schema.changeset(data) |> Repo.update()

        case result do
          {:ok, result} -> {:ok, %{result: %{node: result}}}
          {:error, message} -> {:error, message}
        end
      end

      def delete(%{id: id}, %{context: _}) do
        result = Repo.get!(@schema, id) |> Repo.delete()

        case result do
          {:ok, result} ->
            {:ok, %{deleted_id: Base.encode64("entry:#{id}"), result: %{node: result}}}

          {:error, message} ->
            {:error, message}
        end
      end

      defp get_list_fields(info) do
        [%{selections: selections} | _] = Absinthe.Resolution.project(info)
        node = selections |> Enum.find(&(&1.name == "node"))

        node.selections
        |> Enum.map(fn x ->
          x.name |> ProperCase.snake_case() |> String.to_atom()
        end)
        |> Enum.filter(&(&1 != "__typename"))
        |> MapSet.new()
        |> MapSet.intersection(MapSet.new(@schema.__schema__(:fields)))
        |> Enum.to_list()
      end

      defp get_filter(params) do
        case params do
          %{filter: filter} -> Buzzcms.FilterParser.parse(filter, @filter_definition)
          _ -> dynamic([p], true)
        end
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
  end
end
