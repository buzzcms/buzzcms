defmodule BuzzcmsWeb.ResolverHelper do
  alias Buzzcms.Repo
  import Ecto.Query
  alias Absinthe.Relay.Connection

  @spec list(
          any(),
          any(),
          [{:fields, any} | {:foreign_fields, any}],
          keyword()
        ) ::
          {:ok, any()}
  def list(params, schema, filter_definition, opts) do
    query =
      case Keyword.get(opts, :parse_addition_filter) do
        parse_addition_filter when is_function(parse_addition_filter) ->
          schema |> parse_addition_filter.(params)

        _ ->
          schema
      end
      |> FilterParser.FilterParser.parse(params[:filter], filter_definition)

    {:ok, result} = get_paging(query, params, opts)
    count = Repo.aggregate(query, :count)
    {:ok, result |> Map.put(:count, count)}
  end

  def create(schema, %{data: data}, %{context: %{role: "admin"}} = _info) do
    result =
      struct(schema)
      |> schema.changeset(data)
      |> Repo.insert()

    case result do
      {:ok, result} -> {:ok, %{result: %{node: Repo.get(schema, result.id)}}}
      {:error, message} -> {:error, message}
    end
  end

  def create(_schema, _, %{context: _context} = _info) do
    {:error, "Not authorized"}
  end

  def edit(schema, %{id: id, data: data}, %{context: %{role: "admin"}}) do
    result = Repo.get!(schema, id) |> schema.changeset(data) |> Repo.update()

    case result do
      {:ok, result} -> {:ok, %{result: %{node: result}}}
      {:error, message} -> {:error, message}
    end
  end

  def edit(_schema, _, %{context: _context} = _info) do
    {:error, "Not authorized"}
  end

  def delete(schema, %{id: id}, %{context: %{role: "admin"}}) do
    result = Repo.get!(schema, id) |> Repo.delete()

    case result do
      {:ok, result} ->
        {:ok, %{deleted_id: Base.encode64("entry:#{id}"), result: %{node: result}}}

      {:error, message} ->
        {:error, message}
    end
  end

  def delete(_schema, _, %{context: _context} = _info) do
    {:error, "Not authorized"}
  end

  defp get_order_by(schema, %{order_by: order}) when is_list(order) do
    order
    |> Enum.reduce(schema, fn %{field: field_name, direction: order_direction}, acc_schema ->
      field_name = field_name |> String.to_atom()

      acc_schema
      |> order_by(^Keyword.new([{order_direction, field_name}]))
    end)
  end

  defp get_order_by(schema, _), do: schema

  defp get_paging(query, %{offset: offset} = params, opts) do
    get_order_by = Keyword.get(opts, :get_order_by) || (&get_order_by/2)
    {:ok, :forward, limit} = Connection.limit(params |> Map.delete(:offset))

    query
    |> limit(^limit)
    |> offset(^offset)
    |> get_order_by.(params)
    |> Repo.all()
    |> Connection.from_slice(offset)
  end

  defp get_paging(query, params, opts) do
    get_order_by = Keyword.get(opts, :get_order_by) || (&get_order_by/2)

    Absinthe.Relay.Connection.from_query(
      query
      |> get_order_by.(params),
      &Repo.all/1,
      params
    )
  end
end
