defmodule BuzzcmsWeb.EntryTypeTaxonomyResolver do
  import Ecto.Query
  alias Ecto.Multi
  alias Buzzcms.Repo
  alias Buzzcms.Schema.{EntryType, EntryTypeTaxonomy, Taxonomy}

  def create(
        %{data: data},
        %{context: %{role: "admin"}}
      ) do
    result = %EntryTypeTaxonomy{} |> EntryTypeTaxonomy.changeset(data) |> Repo.insert()

    case result do
      {:ok, _} ->
        {:ok,
         %{
           entry_type: Repo.get(EntryType, data.entry_type_id),
           taxonomy: Repo.get(Taxonomy, data.taxonomy_id)
         }}

      {:error, _} ->
        {:error, "Error occurs"}
    end
  end

  def create(_params, _info) do
    {:error, "Not authorized"}
  end

  def delete(
        %{data: data},
        %{context: %{role: "admin"}}
      ) do
    query =
      from(et in EntryTypeTaxonomy,
        where: et.entry_type_id == ^data.entry_type_id and et.taxonomy_id == ^data.taxonomy_id
      )

    case Repo.delete_all(query) do
      {1, _} ->
        {:ok,
         %{
           entry_type: Repo.get(EntryType, data.entry_type_id),
           taxonomy: Repo.get(Taxonomy, data.taxonomy_id)
         }}

      {:error, _} ->
        {:error, "Error occurs"}
    end
  end

  def delete(_params, _info) do
    {:error, "Not authorized"}
  end

  def edit_position(
        %{entry_type_id: entry_type_id, taxonomy_ids: taxonomy_ids},
        %{context: %{role: "admin"}}
      )
      when is_list(taxonomy_ids) do
    multi =
      Multi.new()
      |> Multi.update(
        :entry_type,
        Repo.get(EntryType, entry_type_id)
        |> EntryType.edit_changeset(%{
          config: %{taxonomies_layout: taxonomy_ids}
        })
      )

    taxonomy_ids
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {taxonomy_id, position}, multi_acc ->
      Multi.run(
        multi_acc,
        {:entry_type_taxonomy, taxonomy_id},
        fn repo, _ ->
          result =
            from(etf in EntryTypeTaxonomy,
              where: etf.taxonomy_id == ^taxonomy_id and etf.entry_type_id == ^entry_type_id,
              update: [set: [position: ^position]]
            )
            |> repo.update_all([])

          {:ok, result}
        end
      )
    end)
    |> Repo.transaction()

    {:ok, %{entry_type: Repo.get(EntryType, entry_type_id)}}
  end
end
