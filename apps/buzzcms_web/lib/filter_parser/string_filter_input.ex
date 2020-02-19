defmodule FilterParser.StringFilterInput do
  defstruct [:eq, :neq, :ilike, :like, :in]
  use ExConstructor
end

defimpl FilterParser.ItemParser, for: FilterParser.StringFilterInput do
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
      :neq -> join_exp(acc, dynamic([p], field(p, ^field_name) != ^value))
      :ilike -> join_exp(acc, dynamic([p], ilike(field(p, ^field_name), ^value)))
      :like -> join_exp(acc, dynamic([p], like(field(p, ^field_name), ^value)))
      :in -> join_exp(acc, dynamic([p], field(p, ^field_name) in ^value))
      _ -> acc
    end
  end
end
