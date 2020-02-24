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
    field(:taxon, non_null(:taxon), resolve: dataloader(Data, :taxon))
    field(:product, :product, resolve: dataloader(Data, :product))

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

    field(:state, non_null(:string))
    field(:published_at, non_null(:datetime))
    field(:created_at, non_null(:datetime))
    field(:updated_at, non_null(:datetime))
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

  input_object :entry_filter_input do
    field(:id, :id_filter_input)
    field(:slug, :string_filter_input)
    field(:title, :string_filter_input)
    field(:state, :string_filter_input)
    field(:taxon_id, :id_filter_input)
    field(:taxons_id, :foreign_filter_input)
    field(:entry_type_id, :id_filter_input)
  end

  object :entry_queries do
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
