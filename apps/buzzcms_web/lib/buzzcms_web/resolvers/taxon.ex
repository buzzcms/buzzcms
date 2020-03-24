defmodule BuzzcmsWeb.TaxonResolver do
  alias FilterParser.{IdFilterInput, StringFilterInput, BooleanFilterInput, LtreeFilterInput}
  @schema Buzzcms.Schema.Taxon
  @filter_definition [
    fields: [
      {:id, IdFilterInput},
      {:slug, StringFilterInput},
      {:title, StringFilterInput},
      {:is_root, BooleanFilterInput},
      {:featured, BooleanFilterInput},
      {:path, LtreeFilterInput},
      {:slug_path, LtreeFilterInput},
      {:parent_id, IdFilterInput},
      {:taxonomy_id, IdFilterInput},
      {:state, StringFilterInput}
    ]
  ]

  use BuzzcmsWeb.Resolver

  def list(params, %{context: _} = _info) do
    ResolverHelper.list(params, @schema, @filter_definition,
      parse_addition_filter: fn schema, params ->
        schema
        |> parse_addition_filter(params)
      end
    )
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
