defmodule BuzzcmsWeb.Resolver do
  defmacro __using__(_opts) do
    quote do
      alias Buzzcms.Repo
      import Ecto.Query

      def list(params, %{context: _} = _info) do
        query =
          @schema
          |> FilterParser.FilterParser.parse(params[:filter], @filter_definition)
          |> order_by(^get_order_by(params))

        {:ok, result} = Absinthe.Relay.Connection.from_query(query, &Repo.all/1, params)
        count = Repo.aggregate(query, :count)
        {:ok, result |> Map.put(:count, count)}
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
