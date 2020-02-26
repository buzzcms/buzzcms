defmodule BuzzcmsWeb.Schema.EntryTaxons do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Ecto.Query
  import Absinthe.Resolution.Helpers

  alias Buzzcms.Repo
  alias Buzzcms.Schema.{Entry, EntryTaxon}
  alias BuzzcmsWeb.Data

  input_object :entry_taxon_input do
    field :entry_id, non_null(:string)
    field :taxon_id, non_null(:string)
    field :group, :string
  end

  node object(:entry_taxon) do
    field :entry, non_null(:entry), resolve: dataloader(Data, :entry)
    field :taxon, non_null(:taxon), resolve: dataloader(Data, :taxon)
    field :group, :string
  end

  object :entry_taxon_mutations do
    payload field(:create_entry_taxon) do
      input do
        field(:data, :entry_taxon_input)
      end

      output do
        field(:entry, :entry)
        field(:taxon, :taxon)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, data: [entry_id: :entry, taxon_id: :taxon])

      resolve(fn %{data: data}, %{context: _} ->
        result = %EntryTaxon{} |> EntryTaxon.changeset(data) |> Repo.insert()

        case result do
          {:ok, _} -> {:ok, %{entry: Repo.get(Entry, data.entry_id)}}
          {:error, _} -> {:error, "Error occurs"}
        end
      end)
    end

    payload field(:delete_entry_taxon) do
      input do
        field(:data, :entry_taxon_input)
      end

      output do
        field(:entry, :entry)
        field(:taxon, :taxon)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, data: [entry_id: :entry, taxon_id: :taxon])

      resolve(fn %{data: data}, %{context: _} ->
        query =
          from(et in EntryTaxon,
            where: et.entry_id == ^data.entry_id and et.taxon_id == ^data.taxon_id
          )

        case Repo.delete_all(query) do
          {1, _} -> {:ok, %{entry: Repo.get(Entry, data.entry_id)}}
          {:error, _} -> {:error, "Error occurs"}
        end
      end)
    end
  end
end
