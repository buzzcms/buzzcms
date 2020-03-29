defmodule BuzzcmsWeb.Schema.Taxons do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers

  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.TaxonResolver

  node object(:taxon_breadcrumb) do
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :taxonomy, non_null(:taxonomy)
  end

  node object(:taxon) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :subtitle, :string
    field :description, :string
    field :featured, :boolean
    field :body, :string
    field :rich_text, :json
    field :is_root, :boolean
    field :path, :string
    field :slug_path, :string
    field :image, :string
    field :images, non_null(list_of(non_null(:image_item)))
    field :breadcrumbs, non_null(list_of(non_null(:taxon_breadcrumb)))
    field :entries_count, :integer
    field :taxonomy_id, non_null(:id)
    field :parent, :taxon, resolve: dataloader(Data, :parent)
    field :parent_id, :id
    field :position, :integer
    field :taxonomy, non_null(:taxonomy), resolve: dataloader(Data, :taxonomy)
    field :taxons, non_null(list_of(non_null(:taxon))), resolve: dataloader(Data, :taxons)
    field :state, non_null(:string)
    field :seo, :seo
  end

  connection(node_type: :taxon) do
    field :count, non_null(:integer)

    edge do
      field :node, non_null(:taxon)
    end
  end

  input_object :taxon_input do
    field :slug, :string
    field :title, :string
    field :subtitle, :string
    field :description, :string
    field :featured, :boolean
    field :body, :string
    field :rich_text, :json
    field :image, :string
    field :images, list_of(non_null(:image_item_input))
    field :taxonomy_id, :id
    field :parent_id, :id
    field :position, :integer
    field :seo, :seo_input
  end

  input_object :create_taxon_data_input do
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :subtitle, :string
    field :description, :string
    field :featured, :boolean
    field :body, :string
    field :rich_text, :json
    field :image, :string
    field :images, list_of(non_null(:image_item_input))
    field :taxonomy_id, :id
    field :parent_id, :id
    field :position, :integer
    field :seo, :seo_input
  end

  input_object :taxon_filter_input do
    field :id, :id_filter_input
    field :slug, :string_filter_input
    field :title, :string_filter_input
    field :is_root, :boolean_filter_input
    field :path, :ltree_filter_input
    field :slug_path, :ltree_filter_input
    field :state, :string_filter_input
    field :taxonomy_id, :id_filter_input
    field :taxonomy_code, :string
    field :featured, :boolean_filter_input
  end

  input_object :edit_taxon_tree_item_input do
    field :_id, :id
    field :parent_id, :id
    field :position, :integer
  end

  object :taxon_queries do
    connection field(:taxons, node_type: :taxon) do
      arg(:offset, :integer)
      arg(:filter, :taxon_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      resolve(&TaxonResolver.list/2)
    end
  end

  object :taxon_mutations do
    payload field(:create_taxon) do
      input do
        field(:data, :create_taxon_data_input)
      end

      output do
        field(:result, :taxon_edge)
      end

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

      middleware(Absinthe.Relay.Node.ParseIDs, id: :taxon)
      resolve(&TaxonResolver.edit/2)
    end

    payload field(:delete_taxon) do
      input do
        field(:id, :id)
      end

      output do
        field(:result, :taxon_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :taxon)
      resolve(&TaxonResolver.delete/2)
    end

    payload field(:edit_taxon_tree) do
      input do
        field(:data, non_null(list_of(non_null(:edit_taxon_tree_item_input))))
      end

      output do
        field(:result, list_of(:taxon_edge))
      end

      resolve(&TaxonResolver.edit_taxon_tree/2)
    end
  end
end
