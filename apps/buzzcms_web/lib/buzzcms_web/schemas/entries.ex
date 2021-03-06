defmodule BuzzcmsWeb.Schema.Entries do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  import Absinthe.Resolution.Helpers
  alias BuzzcmsWeb.Data
  alias BuzzcmsWeb.EntryResolver

  enum :entry_state do
    value(:draft, as: "draft")
    value(:published, as: "published")
    value(:archive, as: "archive")
    value(:trash, as: "trash")
  end

  node object(:entry) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :subtitle, :string
    field :description, :string
    field :featured, :boolean
    field :body, :string
    field :rich_text, :json
    field :tags, non_null(list_of(non_null(:string)))
    field :image, :string
    field :images, non_null(list_of(non_null(:image_item)))
    field :entry_type, non_null(:entry_type), resolve: dataloader(Data, :entry_type)
    field :taxon, :taxon, resolve: dataloader(Data, :taxon)
    field :product, :product, resolve: dataloader(Data, :product)
    field :state, non_null(:entry_state)
    field :seo, :seo
    field :published_at, non_null(:datetime)
    field :created_by, :user, resolve: dataloader(Data, :created_by)
    field :modified_by, :user, resolve: dataloader(Data, :modified_by)
    field :created_at, non_null(:datetime)
    field :modified_at, non_null(:datetime)

    field :entry_taxons,
          non_null(list_of(non_null(:entry_taxon))),
          resolve: dataloader(Data, :entry_taxons)

    field :taxons,
          non_null(list_of(non_null(:taxon))) do
      arg(:filter, :taxon_filter_input)

      resolve(
        dataloader(Data, fn _, params, _info ->
          {:taxons,
           %{
             params: params,
             filter_definition: BuzzcmsWeb.TaxonResolver.filter_definition()
           }}
        end)
      )
    end

    field :select_values,
          non_null(list_of(non_null(:field_value))),
          resolve: dataloader(Data, :select_values)

    field :integer_values,
          non_null(list_of(non_null(:integer_value))),
          resolve: dataloader(Data, :integer_values)

    field :decimal_values,
          non_null(list_of(non_null(:decimal_value))),
          resolve: dataloader(Data, :decimal_values)

    field :boolean_values,
          non_null(list_of(non_null(:boolean_value))),
          resolve: dataloader(Data, :boolean_values)

    field :json_values,
          non_null(list_of(non_null(:json_value))),
          resolve: dataloader(Data, :json_values)
  end

  connection(node_type: :entry) do
    field(:count, non_null(:integer))

    edge do
      field(:node, non_null(:entry))
    end
  end

  input_object :create_entry_data_input do
    field :slug, non_null(:string)
    field :title, non_null(:string)
    field :subtitle, :string
    field :description, :string
    field :featured, :boolean
    field :body, :string
    field :rich_text, :json
    field :tags, list_of(non_null(:string))
    field :image, :string
    field :images, list_of(non_null(:image_item_input))
    field :taxon_id, :id
    field :entry_type_id, :id
    field :state, :entry_state
    field :published_at, :datetime
    field :seo, :seo_input
  end

  input_object :entry_input do
    field :slug, :string
    field :title, :string
    field :subtitle, :string
    field :description, :string
    field :featured, :boolean
    field :body, :string
    field :rich_text, :json
    field :tags, list_of(non_null(:string))
    field :image, :string
    field :images, list_of(non_null(:image_item_input))
    field :taxon_id, :id
    field :entry_type_id, :id
    field :state, :entry_state
    field :published_at, :datetime
    field :seo, :seo_input
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
    field :any, list_of(non_null(:string))
    field :all, list_of(non_null(:string))
  end

  input_object :entry_field_filter_input do
    field :boolean, list_of(non_null(:entry_boolean_field_filter_input))
    field :integer, list_of(non_null(:entry_integer_field_filter_input))
    field :decimal, list_of(non_null(:entry_decimal_field_filter_input))
    field :select, list_of(non_null(:entry_select_field_filter_input))
  end

  @desc "Filter by entry taxon/taxons slug; only use for the frontend"
  input_object :taxon_slug_filter_input do
    field :taxonomy_code, non_null(:string)
    field :slug, non_null(:string_filter_input)
  end

  input_object :taxon_path_filter_input do
    field :taxonomy_code, non_null(:string)
    field :path, non_null(:ltree_filter_input)
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
    field :sale_price, :decimal_filter_input
    field :is_new_product, :boolean_filter_input
    field :featured, :boolean_filter_input
    field :tags, :array_string_filter_input
    field :entry_type_code, :string
    field :taxon_path, list_of(non_null(:taxon_path_filter_input))
    field :taxons_path, list_of(non_null(:taxon_path_filter_input))
    field :taxon_slug_path, list_of(non_null(:taxon_path_filter_input))
    field :taxons_slug_path, list_of(non_null(:taxon_path_filter_input))
    field :taxon_slug, list_of(non_null(:taxon_slug_filter_input))
    field :taxons_slug, list_of(non_null(:taxon_slug_filter_input))
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
      arg(:offset, :integer)
      arg(:filter, :entry_filter_input)
      resolve(&EntryResolver.get_filter/2)
    end

    connection field(:entries, node_type: :entry) do
      arg(:filter, :entry_filter_input)
      arg(:order_by, list_of(non_null(:order_by_input)))
      resolve(&EntryResolver.list/2)
    end
  end

  object :entry_mutations do
    payload field(:create_entry) do
      input do
        field(:data, :create_entry_data_input)
      end

      output do
        field(:result, :entry_edge)
      end

      resolve(&EntryResolver.create/2)
    end

    payload field(:edit_entry) do
      input do
        field :id, non_null(:id)
        field(:data, :entry_input)
      end

      output do
        field(:result, :entry_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :entry)
      resolve(&EntryResolver.edit/2)
    end

    payload field(:delete_entry) do
      input do
        field :id, non_null(:id)
      end

      output do
        field(:deleted_id, non_null(:id))
        field(:result, :entry_edge)
      end

      middleware(Absinthe.Relay.Node.ParseIDs, id: :entry)
      resolve(&EntryResolver.delete/2)
    end
  end
end
