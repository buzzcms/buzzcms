defmodule BuzzcmsWeb.Schema.Entries do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers
  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.EntryResolver

  @filter_ids [
    filter: [
      id: BuzzcmsWeb.ParseIDsHelper.get_ids(:entry),
      entry_type_id: BuzzcmsWeb.ParseIDsHelper.get_ids(:entry_type),
      taxon_id: BuzzcmsWeb.ParseIDsHelper.get_ids(:taxon),
      taxons_id: BuzzcmsWeb.ParseIDsHelper.get_ids(:taxon)
    ]
  ]
  @input_ids [id: :entry, data: [entry_type_id: :entry_type, taxon_id: :taxon]]

  enum :entry_order_field do
    value(:title)
    value(:created_at)
    value(:updated_at)
    value(:published_at)
    value(:position)
  end

  input_object :entry_order_by_input do
    field(:field, non_null(:entry_order_field))
    field(:direction, non_null(:order_direction))
  end

  node object(:entry) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field(:slug, non_null(:string))
    field(:title, non_null(:string))
    field(:description, :string)
    field(:body, :string)
    field(:rich_text, :json)
    field(:image, :string)
    field(:images, :json)
    field(:entry_type, non_null(:entry_type), resolve: dataloader(Data, :entry_type))
    field(:taxon, :taxon, resolve: dataloader(Data, :taxon))
    field(:product, :product, resolve: dataloader(Data, :product))
    field(:state, non_null(:string))
    field(:published_at, non_null(:datetime))
    field(:created_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))

    field(
      :entry_taxons,
      non_null(list_of(non_null(:entry_taxon))),
      resolve: dataloader(Data, :entry_taxons)
    )

    field(
      :taxons,
      non_null(list_of(non_null(:taxon))),
      resolve: dataloader(Data, :taxons)
    )

    field(
      :select_values,
      non_null(list_of(non_null(:field_value))),
      resolve: dataloader(Data, :select_values)
    )
  end

  connection(node_type: :entry) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:entry))
    end
  end

  input_object :entry_input do
    field(:slug, :string)
    field(:title, :string)
    field(:description, :string)
    field(:body, :string)
    field(:rich_text, :json)
    field(:taxon_id, :string)
    field(:entry_type_id, :string)
  end

  input_object :entry_boolean_field_filter_input do
    field :field, non_null(:string)
    field :eq, :boolean
  end

  input_object :entry_integer_field_filter_input do
    field :field, non_null(:string)
    field :eq, :integer
    field :neq, :integer
    field :gt, :integer
    field :le, :integer
    field :gte, :integer
    field :lte, :integer
  end

  input_object :entry_decimal_field_filter_input do
    field :field, non_null(:string)
    field :eq, :decimal
    field :neq, :decimal
    field :gt, :decimal
    field :le, :decimal
    field :gte, :decimal
    field :lte, :decimal
  end

  input_object :entry_select_field_filter_input do
    field :field, non_null(:string)
    field :eq, :string
    field :in, list_of(non_null(:string))
  end

  input_object :entry_field_filter_input do
    field :boolean, list_of(non_null(:entry_boolean_field_filter_input))
    field :integer, list_of(non_null(:entry_integer_field_filter_input))
    field :decimal, list_of(non_null(:entry_decimal_field_filter_input))
    field :select, list_of(non_null(:entry_select_field_filter_input))
  end

  input_object :entry_filter_input do
    field :id, :id_filter_input
    field :slug, :string_filter_input
    field :title, :string_filter_input
    field :state, :string_filter_input
    field :taxon_id, :id_filter_input
    field :taxons_id, :foreign_filter_input
    field :entry_type_id, :id_filter_input
    field :field, :entry_field_filter_input
  end

  object :select_filter_result do
    field :field_code, non_null(:string)
    field :field_value_code, non_null(:string)
    field :field_name, non_null(:string)
    field :field_value_name, non_null(:string)
    field :count, non_null(:integer)
  end

  object :filter_result do
    field :count, non_null(:integer)
    field :select, non_null(list_of(non_null(:select_filter_result)))
  end

  object :entry_queries do
    field :entry_filter, :filter_result do
      arg(:filter, :entry_filter_input)
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&EntryResolver.get_filter/2)
    end

    connection field(:entries, node_type: :entry) do
      arg(:filter, :entry_filter_input)
      arg(:order_by, list_of(non_null(:entry_order_by_input)))
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&EntryResolver.list/2)
    end
  end

  object :entry_mutations do
    payload field(:create_entry) do
      input do
        field(:data, :entry_input)
      end

      output do
        field(:result, :entry_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&EntryResolver.create/2)
    end

    payload field(:edit_entry) do
      input do
        field(:id, :id)
        field(:data, :entry_input)
      end

      output do
        field(:result, :entry_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&EntryResolver.edit/2)
    end

    payload field(:delete_entry) do
      input do
        field(:id, :id)
      end

      output do
        field(:deleted_id, non_null(:id))
        field(:result, :entry_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&EntryResolver.delete/2)
    end
  end
end
