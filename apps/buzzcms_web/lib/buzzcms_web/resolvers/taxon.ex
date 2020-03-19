defmodule BuzzcmsWeb.TaxonResolver do
  alias FilterParser.{IdFilterInput, StringFilterInput, BooleanFilterInput, LtreeFilterInput}
  @schema Buzzcms.Schema.Taxon
  @filter_definition [
    fields: [
      {:id, IdFilterInput},
      {:slug, StringFilterInput},
      {:title, StringFilterInput},
      {:is_root, BooleanFilterInput},
      {:path, LtreeFilterInput},
      {:slug_path, LtreeFilterInput},
      {:parent_id, IdFilterInput},
      {:taxonomy_id, IdFilterInput},
      {:state, StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver

  def list(params, %{context: _} = _info) do
    query =
      @schema
      |> FilterParser.FilterParser.parse(params[:filter], @filter_definition)
      |> parse_addition_filter(params)
      |> order_by(^get_order_by(params))

    {:ok, result} = Absinthe.Relay.Connection.from_query(query, &Repo.all/1, params)
    count = Repo.aggregate(query, :count)
    {:ok, result |> Map.put(:count, count)}
  end

  defp parse_addition_filter(schema, %{filter: filter}) do
    filter
    |> Enum.reduce(schema, fn {key, value}, schema_acc ->
      case key do
        :taxonomy_code ->
          from e in schema_acc,
            join: t in Buzzcms.Schema.Taxonomy,
            on: e.taxonomy_id == t.id,
            where: t.code == ^value

        _ ->
          schema_acc
      end
    end)
  end

  defp parse_addition_filter(schema, _), do: schema
end
