defmodule BuzzcmsWeb.EntryResolver do
  import Ecto.Query
  alias Buzzcms.Schema.{EntrySelectValue, Field, FieldValue, Product, Variant}
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
      |> parse_product_filter(params)
      |> parse_addition_filter(params)
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

    # |> IO.inspect(label: "Filter query")

    {:ok,
     %{
       count: Repo.aggregate(entry_filter_query, :count),
       select: get_select_field_stats(entry_filter_query)
     }}
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
        group_by: [f.code, f.display_name, fv.code, fv.display_name, f.position, fv.position],
        order_by: [f.position, fv.position],
        select: %{
          field_code: f.code,
          field_name: f.display_name,
          field_value_code: fv.code,
          field_value_name: fv.display_name,
          count: count()
        }

    Repo.all(query)
  end

  defp parse_addition_filter(schema, %{filter: filter}) do
    filter
    |> Enum.reduce(schema, fn {key, value}, schema_acc ->
      case key do
        :entry_type_code ->
          from e in schema_acc,
            join: et in Buzzcms.Schema.EntryType,
            on: e.entry_type_id == et.id,
            where: et.code == ^value

        :taxon_slug ->
          %{taxonomy_code: taxonomy_code, slug: slug} = value

          from e in schema_acc,
            join: t in Buzzcms.Schema.Taxon,
            on: e.taxon_id == t.id,
            join: tx in Buzzcms.Schema.Taxonomy,
            on: t.taxonomy_id == tx.id,
            where: t.slug == ^slug and tx.code == ^taxonomy_code

        :taxons_slug ->
          %{taxonomy_code: taxonomy_code, slug: slug} = value

          from e in schema_acc,
            join: et in Buzzcms.Schema.EntryTaxon,
            on: e.id == et.entry_id,
            join: t in Buzzcms.Schema.Taxon,
            on: t.id == et.taxon_id,
            join: tx in Buzzcms.Schema.Taxonomy,
            on: t.taxonomy_id == tx.id,
            where: t.slug == ^slug and tx.code == ^taxonomy_code

        _ ->
          schema_acc
      end
    end)
  end

  defp parse_addition_filter(schema, _), do: schema

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

    # |> IO.inspect(label: "Select Query")
  end

  defp parse_entry_field_filter(schema, _), do: schema

  defp parse_product_filter(schema, %{filter: %{sale_price: _} = product_filter}) do
    schema =
      from e in schema,
        join: p in Product,
        on: p.entry_id == e.id,
        as: :p,
        join: v in Variant,
        on: p.id == v.product_id and v.is_master == true,
        as: :v

    product_filter
    |> Enum.reduce(schema, fn {field_name, filter_item}, acc_schema ->
      case field_name do
        :sale_price ->
          filter_item
          |> Enum.reduce(acc_schema, fn {compare_type, value}, next_acc_schema ->
            case compare_type do
              :eq -> where(next_acc_schema, [v: p], field(p, ^field_name) == ^value)
              :gt -> where(next_acc_schema, [v: p], field(p, ^field_name) > ^value)
              :lt -> where(next_acc_schema, [v: p], field(p, ^field_name) < ^value)
              :gte -> where(next_acc_schema, [v: p], field(p, ^field_name) >= ^value)
              :lte -> where(next_acc_schema, [v: p], field(p, ^field_name) <= ^value)
            end
          end)

        _ ->
          acc_schema
      end

      # |> IO.inspect(label: "Where")
    end)
  end

  defp parse_product_filter(schema, _), do: schema

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
    sub_schema =
      filter
      |> Enum.reduce(
        from(esf in EntrySelectValue,
          join: fv in FieldValue,
          on: esf.field_value_id == fv.id,
          as: :fv,
          join: f in Field,
          on: fv.field_id == f.id,
          distinct: esf.entry_id,
          where: f.code == ^field_name
        ),
        fn {compare_type, value}, schema_acc ->
          case compare_type do
            :eq -> schema_acc |> where([fv: fv], fv.code == ^value)
            :in -> schema_acc |> where([fv: fv], fv.code in ^value)
            _ -> schema_acc
          end
        end
      )

    # |> IO.inspect(label: "Subquery")

    schema |> join(:inner, [p], sub in subquery(sub_schema), on: p.id == sub.entry_id)
  end
end
