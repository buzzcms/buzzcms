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

  def filter_definition, do: @filter_definition

  def list(params, %{context: _} = _info) do
    BuzzcmsWeb.ResolverHelper.list(params, @schema, @filter_definition,
      parse_addition_filter: fn schema, params ->
        schema
        |> parse_addition_filter(params)
      end
    )
  end

  def edit_taxon_tree(
        %{data: data},
        %{context: %{role: "admin"}}
      ) do
    taxons =
      data
      |> Enum.map(fn %{_id: id, parent_id: parent_id, position: position} ->
        %{
          id: String.to_integer(id),
          parent_id:
            case parent_id do
              nil -> nil
              parent_id -> String.to_integer(parent_id)
            end,
          position: position
        }
      end)

    Ecto.Multi.new()
    |> Ecto.Multi.run(:create_tmp_table, fn repo, _ ->
      repo.query("""
      CREATE TEMP TABLE tmp_taxon AS
      SELECT id, parent_id, position FROM taxon LIMIT 0;
      """)
    end)
    |> Ecto.Multi.insert_all(:insert_tmp_taxons, "tmp_taxon", taxons)
    |> Ecto.Multi.run(:update_taxons, fn repo, _ ->
      repo.query("""
      UPDATE taxon
      SET parent_id = tmp_taxon.parent_id, position = tmp_taxon.position
      FROM tmp_taxon
      WHERE tmp_taxon.id = taxon.id;
      """)
    end)
    |> Ecto.Multi.run(:drop_tmp_table, fn repo, _ ->
      repo.query("DROP TABLE tmp_taxon")
    end)
    |> Buzzcms.Repo.transaction()

    {:ok, %{result: []}}
  end

  def edit_taxon_tree(_params, _info) do
    {:error, "Not authorized"}
  end

  defp parse_addition_filter(schema, %{filter: filter}) when map_size(filter) > 0 do
    filter
    |> Map.take([:taxonomy_code])
    |> Enum.reduce(schema, fn {key, value}, schema_acc ->
      case key do
        :taxonomy_code ->
          from e in schema_acc,
            join: t in Buzzcms.Schema.Taxonomy,
            on: e.taxonomy_id == t.id,
            where: t.code == ^value
      end
    end)
  end

  defp parse_addition_filter(schema, _), do: schema
end
