defmodule BuzzcmsWeb.EntryTypeTaxonomyResolver do
  import Ecto.Query
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
end
