defmodule FilterParser.LtreeFilterInput do
  defstruct [:match]
  use ExConstructor
end

defimpl FilterParser.ItemParser, for: FilterParser.LtreeFilterInput do
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
      :match -> join_exp(acc, dynamic([p], fragment("? ~ ?", field(p, ^field_name), ^value)))
    end
  end
end
