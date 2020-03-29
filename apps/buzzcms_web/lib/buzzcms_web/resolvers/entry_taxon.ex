defmodule BuzzcmsWeb.EntryTaxonResolver do
  import Ecto.Query
  alias Buzzcms.Repo
  alias Buzzcms.Schema.{Entry, EntryTaxon, Taxon}

  def create(
        %{data: data},
        %{context: %{role: "admin"}}
      ) do
    result = %EntryTaxon{} |> EntryTaxon.changeset(data) |> Repo.insert()

    case result do
      {:ok, _} ->
        {:ok,
         %{
           entry: Repo.get(Entry, data.entry_id),
           taxon: Repo.get(Taxon, data.taxon_id)
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
      from(et in EntryTaxon,
        where: et.entry_id == ^data.entry_id and et.taxon_id == ^data.taxon_id
      )

    case Repo.delete_all(query) do
      {1, _} ->
        {:ok,
         %{
           entry: Repo.get(Entry, data.entry_id),
           taxon: Repo.get(Taxon, data.taxon_id)
         }}

      {:error, _} ->
        {:error, "Error occurs"}
    end
  end

  def delete(_params, _info) do
    {:error, "Not authorized"}
  end
end
