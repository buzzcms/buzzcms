defmodule FilterParser.FilterParser do
  import Ecto.Query
  import FilterParser.Helper

  alias FilterParser.ItemParser

  def parse(schema, filter, fields: fields, foreign_fields: foreign_fields) do
    parse(schema, filter, fields: fields || [])
    |> FilterParser.ForeignFilterInput.parse(filter, foreign_fields)
  end

  def parse(schema, filter, fields: fields) do
    where = parse_fields(filter, fields)

    if where do
      schema |> where(^where)
    else
      schema
    end
  end

  defp parse_fields(nil, _fields), do: nil

  defp parse_fields(filter, fields) do
    fields
    |> Enum.reduce(nil, fn {field_name, struct}, acc ->
      case Map.get(filter, field_name) do
        nil ->
          acc

        filter_item ->
          filter_input = struct.new(filter_item)

          case ItemParser.parse(filter_input, field_name) do
            nil -> acc
            result -> join_exp(acc, dynamic([p], ^result))
          end
      end
    end)
  end
end
