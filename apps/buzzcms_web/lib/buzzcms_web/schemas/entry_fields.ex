defmodule BuzzcmsWeb.Schema.EntryFields do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  alias Buzzcms.Repo
  alias Buzzcms.Schema.{Entry}

  node object(:integer_value) do
    field :field_id, non_null(:id)
    field :field, non_null(:field)
    field :value, :integer
  end

  node object(:decimal_value) do
    field :field_id, non_null(:id)
    field :field, non_null(:field)
    field :value, :decimal
  end

  node object(:boolean_value) do
    field :field_id, non_null(:id)
    field :field, non_null(:field)
    field :value, :boolean
  end

  node object(:json_value) do
    field :field_id, non_null(:id)
    field :field, non_null(:field)
    field :value, :json
  end

  input_object :integer_value_input do
    field :field_id, non_null(:id)
    field :value, :integer
  end

  input_object :decimal_value_input do
    field :field_id, non_null(:id)
    field :value, :decimal
  end

  input_object :boolean_value_input do
    field :field_id, non_null(:id)
    field :value, :boolean
  end

  input_object :select_value_input do
    field :field_id, non_null(:id)
    field :value, non_null(:id)
  end

  input_object :multi_select_value_input do
    field :field_id, non_null(:id)
    field :value, non_null(list_of(non_null(:id)))
  end

  input_object :json_value_input do
    field :field_id, non_null(:id)
    field :value, :json
  end

  input_object :entry_fields_input do
    field :entry_id, non_null(:id)
    field :select_values, list_of(non_null(:select_value_input))
    field :multi_select_values, list_of(non_null(:multi_select_value_input))
    field :integer_values, list_of(non_null(:integer_value_input))
    field :decimal_values, list_of(non_null(:decimal_value_input))
    field :boolean_values, list_of(non_null(:boolean_value_input))
    field :json_values, list_of(non_null(:json_value_input))
  end

  object :entry_field_mutations do
    payload field(:edit_entry_fields) do
      input do
        field :data, non_null(:entry_fields_input)
      end

      output do
        field(:result, :entry_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs,
        data: [
          entry_id: :entry,
          select_values: [field_id: :field, value: :field_value],
          multi_select_values: [field_id: :field, value: :field_value],
          integer_values: [field_id: :field],
          decimal_values: [field_id: :field],
          boolean_values: [field_id: :field],
          json_values: [field_id: :field]
        ]
      )

      resolve(fn %{data: data}, %{context: _} ->
        IO.inspect(data)

        case {:ok, 1} do
          {:ok, _} -> {:ok, %{entry: Repo.get(Entry, data.entry_id)}}
          {:error, _} -> {:error, "Error occurs"}
        end
      end)
    end
  end
end
