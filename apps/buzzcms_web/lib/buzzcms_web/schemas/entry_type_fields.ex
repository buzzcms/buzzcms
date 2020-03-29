defmodule BuzzcmsWeb.Schema.EntryTypeFields do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Ecto.Query

  alias Buzzcms.Repo
  alias Buzzcms.Schema.{EntryType, EntryTypeField}

  input_object :entry_type_field_input do
    field(:entry_type_id, :id)
    field(:field_id, :id)
  end

  object :entry_type_field_mutations do
    payload field(:create_entry_type_field) do
      input do
        field(:data, :entry_type_field_input)
      end

      output do
        field(:entry_type, :entry_type)
        field(:field, :field)
      end

      resolve(fn %{data: data}, %{context: %{role: "admin"}} ->
        result = %EntryTypeField{} |> EntryTypeField.changeset(data) |> Repo.insert()

        case result do
          {:ok, _} -> {:ok, %{entry_type: Repo.get(EntryType, data.entry_type_id)}}
          {:error, _} -> {:error, "Error occurs"}
        end
      end)
    end

    payload field(:delete_entry_type_field) do
      input do
        field(:data, :entry_type_field_input)
      end

      output do
        field(:entry_type, :entry_type)
        field(:field, :field)
      end

      resolve(fn %{data: data}, %{context: %{role: "admin"}} ->
        query =
          from(et in EntryTypeField,
            where: et.entry_type_id == ^data.entry_type_id and et.field_id == ^data.field_id
          )

        case Repo.delete_all(query) do
          {1, _} -> {:ok, %{entry_type: Repo.get(EntryType, data.entry_type_id)}}
          {:error, _} -> {:error, "Error occurs"}
        end
      end)
    end
  end
end
