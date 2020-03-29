defmodule BuzzcmsWeb.Schema.EntryTypeTaxonomies do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Ecto.Query

  alias Buzzcms.Repo
  alias Buzzcms.Schema.{EntryType, EntryTypeTaxonomy}

  input_object :entry_type_taxonomy_input do
    field(:entry_type_id, :id)
    field(:taxonomy_id, :id)
  end

  object :entry_type_taxonomy_mutations do
    payload field(:create_entry_type_taxonomy) do
      input do
        field(:data, :entry_type_taxonomy_input)
      end

      output do
        field(:entry_type, :entry_type)
        field(:taxonomy, :taxonomy)
      end

      middleware(Absinthe.Relay.Node.ParseIDs,
        data: [entry_type_id: :entry_type, taxonomy_id: :taxonomy]
      )

      resolve(fn %{data: data}, %{context: _} ->
        result = %EntryTypeTaxonomy{} |> EntryTypeTaxonomy.changeset(data) |> Repo.insert()

        case result do
          {:ok, _} -> {:ok, %{entry_type: Repo.get(EntryType, data.entry_type_id)}}
          {:error, _} -> {:error, "Error occurs"}
        end
      end)
    end

    payload field(:delete_entry_type_taxonomy) do
      input do
        field(:data, :entry_type_taxonomy_input)
      end

      output do
        field(:entry_type, :entry_type)
        field(:taxonomy, :taxonomy)
      end

      middleware(Absinthe.Relay.Node.ParseIDs,
        data: [entry_type_id: :entry_type, taxonomy_id: :taxonomy]
      )

      resolve(fn %{data: data}, %{context: _} ->
        query =
          from(et in EntryTypeTaxonomy,
            where: et.entry_type_id == ^data.entry_type_id and et.taxonomy_id == ^data.taxonomy_id
          )

        case Repo.delete_all(query) do
          {1, _} -> {:ok, %{entry_type: Repo.get(EntryType, data.entry_type_id)}}
          {:error, _} -> {:error, "Error occurs"}
        end
      end)
    end
  end
end
