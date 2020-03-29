defmodule BuzzcmsWeb.Schema.EntryTypeFields do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

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

      resolve(&BuzzcmsWeb.EntryTypeFieldResolver.create/2)
    end

    payload field(:delete_entry_type_field) do
      input do
        field(:data, :entry_type_field_input)
      end

      output do
        field(:entry_type, :entry_type)
        field(:field, :field)
      end

      resolve(&BuzzcmsWeb.EntryTypeFieldResolver.delete/2)
    end
  end
end
