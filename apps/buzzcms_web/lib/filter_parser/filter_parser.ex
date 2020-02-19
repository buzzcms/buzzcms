defmodule FilterParser.FilterParser do
  import Ecto.Query
  import FilterParser.Helper

  alias FilterParser.ItemParser

  def parse(filter, schema: schema, fields: fields, foreign_fields: foreign_fields) do
    parse(filter, schema: schema, fields: fields)
    |> FilterParser.ForeignFilterInput.parse(filter, foreign_fields)
  end

  def parse(filter, schema: schema, fields: fields) do
    where = parse_fields(filter, fields)

    if where do
      schema |> where(^where)
    else
      schema
    end
  end

  def parse_fields(filter, fields) do
    fields
    |> Enum.reduce(nil, fn {field_name, struct}, acc ->
      case Map.get(filter, field_name) do
        nil ->
          acc

        filter_item ->
          filter_input = struct.new(filter_item)
          filter = ItemParser.parse(filter_input, field_name)
          join_exp(acc, dynamic([p], ^filter))
      end
    end)
  end
end