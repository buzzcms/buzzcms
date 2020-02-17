defmodule Buzzcms.FilterParser do
  import Ecto.Query

  def parse(filter, filter_definition) do
    filter_definition
    |> Enum.reduce(dynamic(true), fn {field_name, filter_type}, acc ->
      field_value = Map.get(filter, field_name)

      if field_value do
        case filter_type do
          :id ->
            dynamic([p], ^acc and field(p, ^field_name) == ^field_value)

          :boolean ->
            dynamic([p], ^acc and field(p, ^field_name) == ^field_value)

          :id_filter_input ->
            dynamic([p], ^acc and ^parse_id(field_name, field_value))

          :string_filter_input ->
            dynamic([p], ^acc and ^parse_string(field_name, field_value))

          :date_filter_input ->
            dynamic([p], ^acc and ^parse_date(field_name, field_value))

          :int_filter_input ->
            dynamic([p], ^acc and ^parse_number(field_name, field_value))

          :float_filter_input ->
            dynamic([p], ^acc and ^parse_number(field_name, field_value))

          _ ->
            acc
        end
      else
        acc
      end
    end)
  end

  def parse_id(field_name, field_value) do
    field_value
    |> Enum.reduce(dynamic(true), fn {compare_type, value}, dynamic ->
      case compare_type do
        :eq -> dynamic([p], ^dynamic and field(p, ^field_name) == ^value)
        :neq -> dynamic([p], ^dynamic and field(p, ^field_name) != ^value)
        :in -> dynamic([p], ^dynamic and field(p, ^field_name) in ^value)
        _ -> dynamic
      end
    end)
  end

  def parse_string(field_name, field_value) do
    field_value
    |> Enum.reduce(dynamic(true), fn {compare_type, value}, dynamic ->
      case compare_type do
        :eq -> dynamic([p], ^dynamic and field(p, ^field_name) == ^value)
        :neq -> dynamic([p], ^dynamic and field(p, ^field_name) != ^value)
        :ilike -> dynamic([p], ^dynamic and ilike(field(p, ^field_name), ^value))
        :like -> dynamic([p], ^dynamic and like(field(p, ^field_name), ^value))
        :in -> dynamic([p], ^dynamic and field(p, ^field_name) in ^value)
        _ -> dynamic
      end
    end)
  end

  def parse_number(field_name, field_value) do
    field_value
    |> Enum.reduce(dynamic(true), fn {compare_type, value}, dynamic ->
      case compare_type do
        :eq -> dynamic([p], ^dynamic and field(p, ^field_name) == ^value)
        :gt -> dynamic([p], ^dynamic and field(p, ^field_name) > ^value)
        :lt -> dynamic([p], ^dynamic and field(p, ^field_name) < ^value)
        :gte -> dynamic([p], ^dynamic and field(p, ^field_name) >= ^value)
        :lte -> dynamic([p], ^dynamic and field(p, ^field_name) <= ^value)
        _ -> dynamic
      end
    end)
  end

  def parse_date(field_name, field_value) do
    field_value
    |> Enum.reduce(dynamic(true), fn {compare_type, value}, dynamic ->
      case compare_type do
        :eq -> dynamic([p], ^dynamic and field(p, ^field_name) == ^value)
        :gt -> dynamic([p], ^dynamic and field(p, ^field_name) > ^value)
        :lt -> dynamic([p], ^dynamic and field(p, ^field_name) < ^value)
        :gte -> dynamic([p], ^dynamic and field(p, ^field_name) >= ^value)
        :lte -> dynamic([p], ^dynamic and field(p, ^field_name) <= ^value)
        _ -> dynamic
      end
    end)
  end
end
