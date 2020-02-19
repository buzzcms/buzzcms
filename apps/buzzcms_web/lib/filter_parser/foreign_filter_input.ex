defmodule FilterParser.ForeignFilterInput do
  defstruct [:eq, :neq, :in, :nin]
  use ExConstructor
  import Ecto.Query
  import FilterParser.Helper

  def parse(schema, filter, fields) do
    fields
    |> Enum.reduce(schema, fn {field_name,
                               {foreign_schema,
                                [
                                  foreign_key: foreign_key,
                                  foreign_filter_field: foreign_filter_field
                                ]}},
                              acc ->
      filter_item = Map.get(filter, field_name)

      if filter_item == nil do
        acc
      else
        where =
          filter_item
          |> Enum.reduce(nil, fn {compare_type, value}, acc ->
            parse_item({compare_type, value}, acc, foreign_filter_field)
          end)

        acc
        |> join(:inner, [p], f in ^foreign_schema, on: p.id == field(f, ^foreign_key))
        |> where(^where)
      end
    end)
  end

  defp parse_item({compare_type, value}, acc, foreign_filter_field) do
    case compare_type do
      :eq -> join_exp(acc, dynamic([p], field(p, ^foreign_filter_field) == ^value))
      :neq -> join_exp(acc, dynamic([p], field(p, ^foreign_filter_field) != ^value))
      :in -> join_exp(acc, dynamic([p], field(p, ^foreign_filter_field) in ^value))
      :nin -> join_exp(acc, dynamic([p], field(p, ^foreign_filter_field) not in ^value))
    end
  end
end
