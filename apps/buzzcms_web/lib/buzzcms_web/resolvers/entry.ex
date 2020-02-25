defmodule BuzzcmsWeb.EntryResolver do
  import Ecto.Query
  alias Buzzcms.Schema.{EntrySelectValue, Field, FieldValue}
  alias FilterParser.{IdFilterInput, StringFilterInput}

  @schema Buzzcms.Schema.Entry

  @filter_definition [
    fields: [
      {:id, IdFilterInput},
      {:slug, StringFilterInput},
      {:title, StringFilterInput},
      {:entry_type_id, IdFilterInput},
      {:taxon_id, IdFilterInput},
      {:state, StringFilterInput}
    ],
    foreign_fields: [
      taxons_id:
        {Buzzcms.Schema.EntryTaxon, [foreign_key: :entry_id, foreign_filter_field: :taxon_id]}
    ]
  ]

  use BuzzcmsWeb.Resolver

  def list(params, %{context: _} = _info) do
    query =
      @schema
      |> FilterParser.FilterParser.parse(params[:filter], @filter_definition)
      |> parse_entry_field_filter(params)
      |> order_by(^get_order_by(params))

    {:ok, result} = Absinthe.Relay.Connection.from_query(query, &Repo.all/1, params)
    count = Repo.aggregate(query, :count)
    {:ok, result |> Map.put(:count, count)}
  end

  def get_filter(params, %{context: _} = _info) do
    entry_filter_query =
      @schema
      |> FilterParser.FilterParser.parse(params[:filter], @filter_definition)
      |> parse_entry_field_filter(params)
      |> IO.inspect(label: "Filter query")

    {:ok, %{select: get_select_field_stats(entry_filter_query)}}
  end

  defp get_select_field_stats(filter_query) do
    query =
      from [e] in subquery(filter_query),
        join: esv in Buzzcms.Schema.EntrySelectValue,
        on: esv.entry_id == e.id,
        join: fv in Buzzcms.Schema.FieldValue,
        on: esv.field_value_id == fv.id,
        join: f in Buzzcms.Schema.Field,
        on: fv.field_id == f.id,
        group_by: [f.code, f.display_name, fv.code, fv.display_name],
        order_by: [desc: count()],
        select: %{
          field_code: f.code,
          field_name: f.display_name,
          field_value_code: fv.code,
          field_value_name: fv.display_name,
          count: count()
        }

    Repo.all(query)
  end

  defp parse_entry_field_filter(schema, %{filter: %{field: entry_field}}) do
    entry_field
    |> Enum.reduce(schema, fn {type, payload}, schema_acc ->
      case type do
        :boolean -> parse_entry_boolean_field_filters(schema_acc, payload)
        :select -> parse_entry_select_field_filters(schema_acc, payload)
        :integer -> parse_entry_select_field_filters(schema_acc, payload)
        :decimal -> parse_entry_number_field_filters(schema_acc, payload)
      end
    end)
  end

  defp parse_entry_field_filter(schema, %{}), do: schema

  defp parse_entry_boolean_field_filters(schema, _filters) do
    # IO.inspect(payload, label: "boolean")
    schema
  end

  defp parse_entry_select_field_filters(schema, filters) do
    # IO.inspect(filters, label: "select")

    filters
    |> Enum.reduce(schema, fn filter, acc -> parse_entry_select_field_filter(acc, filter) end)
  end

  defp parse_entry_number_field_filters(schema, _filters) do
    # IO.inspect(payload, label: "number")
    schema
  end

  defp parse_entry_select_field_filter(schema, %{field: field_name} = filter) do
    joined_schema =
      schema
      |> join(:inner, [p], esf in EntrySelectValue, as: :esf, on: esf.entry_id == p.id)
      |> join(:inner, [p, esf: esf], fv in FieldValue, as: :fv, on: esf.field_value_id == fv.id)
      |> join(:inner, [p, esf: esf, fv: fv], f in Field, as: :f, on: fv.field_id == f.id)
      |> where([f: f], f.code == ^field_name)

    filter
    |> Enum.reduce(
      joined_schema,
      fn {compare_type, value}, schema_acc ->
        case compare_type do
          :eq -> schema_acc |> where([fv: fv], fv.code == ^value)
          :in -> schema_acc |> where([fv: fv], fv.code in ^value)
          _ -> schema_acc
        end
      end
    )
  end
end
