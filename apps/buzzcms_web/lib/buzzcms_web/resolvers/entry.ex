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

  defp parse_entry_boolean_field_filters(schema, payload) do
    IO.inspect(payload, label: "boolean")
    schema
  end

  defp parse_entry_select_field_filters(schema, filters) do
    IO.inspect(filters, label: "select")

    filters
    |> Enum.reduce(schema, fn filter, acc -> parse_entry_select_field_filter(acc, filter) end)
  end

  defp parse_entry_number_field_filters(schema, payload) do
    IO.inspect(payload, label: "number")
    schema
  end

  defp parse_entry_select_field_filter(schema, %{field: field_name} = filter) do
    IO.inspect(filter, label: field_name)

    joined_schema =
      schema
      |> join(:inner, [p], esf in EntrySelectValue, on: esf.entry_id == p.id)
      |> join(:inner, [p, esf], fv in FieldValue, on: esf.field_value_id == fv.id)
      |> join(:inner, [p, esf, fv], f in Field, on: fv.field_id == f.id)
      |> where([_, _, _, f], f.code == ^field_name)

    # |> IO.inspect(label: "Afer join")

    filter
    |> Enum.reduce(
      joined_schema,
      fn {compare_type, value}, schema_acc ->
        case compare_type do
          :eq -> schema_acc |> where([_, _, fv, _f], fv.code == ^value)
          :in -> schema_acc |> where([_, _, fv, _f], fv.code in ^value)
          _ -> schema_acc
        end
      end
    )

    # |> IO.inspect(label: "XXXX")
  end
end
