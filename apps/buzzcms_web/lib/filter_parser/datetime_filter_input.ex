defmodule FilterParser.DateTimeFilterInput do
  defstruct [:eq, :gt, :lt, :gte, :lte]
  use ExConstructor
end

defimpl FilterParser.ItemParser, for: FilterParser.DateTimeFilterInput do
  import Ecto.Query
  import FilterParser.Helper

  def parse(value, field_name, _opts \\ []) do
    value
    |> Map.from_struct()
    |> Enum.reduce(nil, fn {compare_type, value}, acc ->
      parse_item({compare_type, value}, acc, field_name)
    end)
  end

  defp parse_item({_compare_type, nil}, acc, _field_name), do: acc

  defp parse_item({compare_type, value}, acc, field_name) do
    case compare_type do
      :eq -> join_exp(acc, dynamic([p], field(p, ^field_name) == ^value))
      :gt -> join_exp(acc, dynamic([p], field(p, ^field_name) > ^value))
      :lt -> join_exp(acc, dynamic([p], field(p, ^field_name) < ^value))
      :gte -> join_exp(acc, dynamic([p], field(p, ^field_name) >= ^value))
      :lte -> join_exp(acc, dynamic([p], field(p, ^field_name) <= ^value))
    end
  end
end
