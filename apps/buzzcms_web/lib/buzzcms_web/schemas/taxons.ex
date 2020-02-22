defmodule BuzzcmsWeb.Schema.Taxons do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.TaxonResolver

  @filter_ids [
    filter: [
      id: BuzzcmsWeb.ParseIDsHelper.get_ids(:taxon),
      taxonomy_id: BuzzcmsWeb.ParseIDsHelper.get_ids(:taxonomy)
    ]
  ]
  @input_ids [id: :taxon, data: [taxonomy_id: :taxonomy]]

  enum :taxon_order_field do
    value(:title)
    value(:created_at)
    value(:position)
  end

  input_object :taxon_order_by_input do
    field(:field, non_null(:taxon_order_field))
    field(:direction, non_null(:order_direction))
  end

  node object(:taxon) do
    field(:slug, non_null(:string))
    field(:title, non_null(:string))
    field(:description, :string)
    field(:body, :string)
    field(:rich_text, :json)
    field(:is_root, :boolean)
    field(:image, :string)
    field(:images, :json)
    field(:taxonomy_id, non_null(:id))
    field(:taxonomy, non_null(:taxonomy), resolve: dataloader(Data, :taxonomy))
    field(:taxons, non_null(list_of(non_null(:taxon))), resolve: dataloader(Data, :taxons))
  end

  connection(node_type: :taxon) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:taxon))
    end
  end

  input_object :taxon_input do
    field(:slug, :string)
    field(:title, :string)
    field(:taxonomy_id, :string)
  end

  input_object :taxon_filter_input do
    field(:id, :id_filter_input)
    field(:slug, :string_filter_input)
    field(:title, :string_filter_input)
    field(:is_root, :boolean_filter_input)
    field(:state, :string_filter_input)
    field(:taxonomy_id, :id_filter_input)
  end

  object :taxon_queries do
    connection field(:taxons, node_type: :taxon) do
      arg(:filter, :taxon_filter_input)
      arg(:order_by, list_of(non_null(:taxon_order_by_input)))
      middleware(Absinthe.Relay.Node.ParseIDs, @filter_ids)
      resolve(&TaxonResolver.list/2)
    end
  end

  object :taxon_mutations do
    payload field(:create_taxon) do
      input do
        field(:data, :taxon_input)
      end

      output do
        field(:result, :taxon_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&TaxonResolver.create/2)
    end

    payload field(:edit_taxon) do
      input do
        field(:id, :id)
        field(:data, :taxon_input)
      end

      output do
        field(:result, :taxon_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&TaxonResolver.edit/2)
    end

    payload field(:delete_taxon) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :taxon_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, @input_ids)
      resolve(&TaxonResolver.delete/2)
    end
  end
end
