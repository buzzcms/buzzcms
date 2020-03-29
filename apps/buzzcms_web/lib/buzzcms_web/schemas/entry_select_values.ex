defmodule BuzzcmsWeb.Schema.EntrySelectValues do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Ecto.Query

  alias Buzzcms.Repo
  alias Buzzcms.Schema.{Entry, EntrySelectValue}

  input_object :entry_select_value_input do
    field(:entry_id, :id)
    field(:field_id, :id)
    field(:field_value_id, :id)
  end

  object :entry_select_value_mutations do
    payload field(:create_entry_select_value) do
      input do
        field(:data, :entry_select_value_input)
      end

      output do
        field(:entry, :entry)
        field(:field_value, :field_value)
      end

      middleware(Absinthe.Relay.Node.ParseIDs,
        data: [entry_id: :entry, field_id: :field, field_value_id: :field_value]
      )

      resolve(fn %{data: data}, %{context: _} ->
        result = %EntrySelectValue{} |> EntrySelectValue.changeset(data) |> Repo.insert()

        case result do
          {:ok, _} -> {:ok, %{entry: Repo.get(Entry, data.entry_id)}}
          {:error, _} -> {:error, "Error occurs"}
        end
      end)
    end

    payload field(:delete_entry_select_value) do
      input do
        field(:data, :entry_select_value_input)
      end

      output do
        field(:entry, :entry)
        field(:field_value, :field_value)
      end

      middleware(Absinthe.Relay.Node.ParseIDs,
        data: [entry_id: :entry, field_id: :field, field_value_id: :field_value]
      )

      resolve(fn %{data: data}, %{context: _} ->
        query =
          from(et in EntrySelectValue,
            where: et.entry_id == ^data.entry_id and et.field_value_id == ^data.field_value_id
          )

        case Repo.delete_all(query) do
          {1, _} -> {:ok, %{entry: Repo.get(Entry, data.entry_id)}}
          {:error, _} -> {:error, "Error occurs"}
        end
      end)
    end
  end
end
