defmodule BuzzcmsWeb.UpdateEntryFieldsInput do
  defstruct entry_id: nil,
            decimal_values: [],
            integer_values: [],
            boolean_values: [],
            json_values: [],
            select_values: [],
            multi_select_values: []

  use ExConstructor
end

defmodule BuzzcmsWeb.Schema.EntryFields do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers
  import Ecto.Query
  alias BuzzcmsWeb.Data
  alias Buzzcms.Repo

  alias Buzzcms.Schema.{
    Entry,
    EntryIntegerValue,
    EntryDecimalValue,
    EntryBooleanValue,
    EntryJsonValue,
    EntrySelectValue,
    Field
  }

  object(:integer_value) do
    field(:field_id, non_null(:id))
    field(:field, non_null(:field), resolve: dataloader(Data, :field))
    field(:value, :integer)
  end

  object(:decimal_value) do
    field(:field_id, non_null(:id))
    field(:field, non_null(:field), resolve: dataloader(Data, :field))
    field(:value, :decimal)
  end

  object(:boolean_value) do
    field(:field_id, non_null(:id))
    field(:field, non_null(:field), resolve: dataloader(Data, :field))
    field(:value, :boolean)
  end

  object(:json_value) do
    field(:field_id, non_null(:id))
    field(:field, non_null(:field), resolve: dataloader(Data, :field))
    field(:value, :json)
  end

  input_object :integer_value_input do
    field(:field_id, non_null(:id))
    field(:value, :integer)
  end

  input_object :decimal_value_input do
    field(:field_id, non_null(:id))
    field(:value, :decimal)
  end

  input_object :boolean_value_input do
    field(:field_id, non_null(:id))
    field(:value, :boolean)
  end

  input_object :select_value_input do
    field(:field_id, non_null(:id))
    field(:value, non_null(:id))
  end

  input_object :multi_select_value_input do
    field(:field_id, non_null(:id))
    field(:value, non_null(list_of(non_null(:id))))
  end

  input_object :json_value_input do
    field(:field_id, non_null(:id))
    field(:value, :json)
  end

  input_object :entry_fields_input do
    field(:entry_id, non_null(:id))
    field(:select_values, list_of(non_null(:select_value_input)))
    field(:multi_select_values, list_of(non_null(:multi_select_value_input)))
    field(:integer_values, list_of(non_null(:integer_value_input)))
    field(:decimal_values, list_of(non_null(:decimal_value_input)))
    field(:boolean_values, list_of(non_null(:boolean_value_input)))
    field(:json_values, list_of(non_null(:json_value_input)))
  end

  object :entry_field_mutations do
    payload field(:edit_entry_fields) do
      input do
        field(:data, non_null(:entry_fields_input))
      end

      output do
        field(:result, :entry_edge)
      end

      resolve(fn %{data: data}, %{context: _} ->
        %{
          entry_id: entry_id,
          decimal_values: decimal_values,
          integer_values: integer_values,
          boolean_values: boolean_values,
          json_values: json_values,
          select_values: select_values,
          multi_select_values: multi_select_values
        } = BuzzcmsWeb.UpdateEntryFieldsInput.new(data)

        upsert_entry_values({EntryDecimalValue, entry_id, decimal_values})
        upsert_entry_values({EntryIntegerValue, entry_id, integer_values})
        upsert_entry_values({EntryBooleanValue, entry_id, boolean_values})
        upsert_entry_values({EntryJsonValue, entry_id, json_values})
        upsert_entry_select_values({entry_id, select_values})
        upsert_entry_multi_select_values({entry_id, multi_select_values})

        {:ok, %{result: %{node: Repo.get(Entry, entry_id)}}}
      end)
    end
  end

  defp upsert_entry_values({schema, entry_id, values}) do
    Repo.insert_all(
      schema,
      values
      |> Enum.filter(&Map.has_key?(&1, :value))
      |> Enum.map(fn %{field_id: field_id, value: value} ->
        %{
          entry_id: String.to_integer(entry_id),
          field_id: String.to_integer(field_id),
          value: value
        }
      end),
      conflict_target: [:entry_id, :field_id],
      on_conflict: {:replace, [:value]}
    )
  end

  defp upsert_entry_select_values({entry_id, values}) do
    Repo.insert_all(
      EntrySelectValue,
      values
      |> Enum.map(fn %{field_id: field_id, value: value} ->
        %{
          entry_id: String.to_integer(entry_id),
          field_id: String.to_integer(field_id),
          field_value_id: String.to_integer(value)
        }
      end),
      on_conflict: :nothing
    )

    field_value_ids = values |> Enum.map(& &1.value) |> IO.inspect()

    Repo.delete_all(
      from sv in EntrySelectValue,
        join: f in Field,
        on: sv.field_id == f.id,
        where:
          f.type in ["select", "radio_group"] and sv.entry_id == ^entry_id and
            sv.field_value_id not in ^field_value_ids
    )
  end

  defp upsert_entry_multi_select_values({entry_id, values}) do
    Repo.insert_all(
      EntrySelectValue,
      values
      |> Enum.reduce([], fn %{field_id: field_id, value: value}, list ->
        value
        |> Enum.map(
          &%{
            entry_id: String.to_integer(entry_id),
            field_id: String.to_integer(field_id),
            field_value_id: String.to_integer(&1)
          }
        )
        |> Enum.concat(list)
      end),
      on_conflict: :nothing
    )

    field_value_ids = values |> Enum.map(& &1.value) |> List.flatten() |> IO.inspect()

    Repo.delete_all(
      from sv in EntrySelectValue,
        join: f in Field,
        on: sv.field_id == f.id,
        where:
          f.type in ["multi_select", "checkbox_group"] and sv.entry_id == ^entry_id and
            sv.field_value_id not in ^field_value_ids
    )
  end
end
