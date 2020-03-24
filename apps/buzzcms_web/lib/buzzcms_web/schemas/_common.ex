defmodule BuzzcmsWeb.Schema.Common do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Buzzcms.Repo

  alias Buzzcms.Schema.{
    Entry,
    EntryType,
    Field,
    FieldValue,
    Taxonomy,
    Taxon,
    Route,
    Form,
    ConfigItem
  }

  scalar :json, name: "Json" do
    description("""
    The `Json` scalar type represents arbitrary json string data, represented as UTF-8
    character sequences. The Json type is most often used to represent a free-form
    human-readable json string.
    """)

    serialize(&encode/1)
    parse(&decode/1)

    @spec decode(Absinthe.Blueprint.Input.String.t()) :: {:ok, term()} | :error
    @spec decode(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
    defp decode(%Absinthe.Blueprint.Input.String{value: value}) do
      case Jason.decode(value) do
        {:ok, result} -> {:ok, result}
        _ -> :error
      end
    end

    defp decode(%Absinthe.Blueprint.Input.Null{}) do
      {:ok, nil}
    end

    defp decode(_) do
      :error
    end

    defp encode(value), do: value
  end

  enum :order_direction do
    value(:asc)
    value(:asc_nulls_last)
    value(:asc_nulls_first)
    value(:desc)
    value(:desc_nulls_last)
    value(:desc_nulls_first)
  end

  input_object :order_by_input do
    field :field, non_null(:string)
    field :direction, non_null(:order_direction)
  end

  object :heading do
    field(:title, :string)
    field(:subtitle, :string)
  end

  object :seo do
    field(:title, :string)
    field(:description, :string)
    field(:keywords, list_of(non_null(:string)))
  end

  input_object :heading_input do
    field(:title, :string)
    field(:subtitle, :string)
  end

  input_object :seo_input do
    field(:title, :string)
    field(:description, :string)
    field(:keywords, list_of(non_null(:string)))
  end

  object :image_item do
    field(:id, non_null(:string)) do
      resolve(fn _parent, %{source: source} -> {:ok, source["id"]} end)
    end

    field(:caption, :string) do
      resolve(fn _parent, %{source: source} -> {:ok, source["caption"]} end)
    end
  end

  input_object :image_item_input do
    field(:id, :string)
    field(:caption, :string)
  end

  input_object :boolean_filter_input do
    field(:eq, :boolean)
    field(:neq, :boolean)
  end

  input_object :id_filter_input do
    field(:eq, :id)
    field(:neq, :id)
    field(:in, list_of(non_null(:id)))
    field(:nin, list_of(non_null(:id)))
  end

  input_object :array_string_filter_input do
    field :any, list_of(non_null(:id))
    field :all, list_of(non_null(:id))
  end

  input_object :foreign_filter_input do
    field(:eq, :id)
    field(:neq, :id)
    field(:in, list_of(non_null(:id)))
    field(:nin, list_of(non_null(:id)))
  end

  input_object :string_filter_input do
    field(:eq, :string)
    field(:neq, :string)
    field(:in, list_of(non_null(:string)))
    field(:like, :string)
    field(:ilike, :string)
  end

  input_object :int_filter_input do
    field(:eq, :integer)
    field(:neq, :integer)
    field(:lt, :integer)
    field(:gt, :integer)
    field(:lte, :integer)
    field(:gte, :integer)
    field(:in, list_of(non_null(:integer)))
  end

  input_object :float_filter_input do
    field(:eq, :float)
    field(:neq, :float)
    field(:lt, :float)
    field(:gt, :float)
    field(:lte, :float)
    field(:gte, :float)
    field(:in, list_of(non_null(:float)))
  end

  input_object :decimal_filter_input do
    field(:eq, :decimal)
    field(:neq, :decimal)
    field(:lt, :decimal)
    field(:gt, :decimal)
    field(:lte, :decimal)
    field(:gte, :decimal)
    field(:in, list_of(non_null(:decimal)))
  end

  input_object :date_filter_input do
    field(:eq, :date)
    field(:neq, :date)
    field(:lt, :date)
    field(:gt, :date)
    field(:lte, :date)
    field(:gte, :date)
    field(:in, list_of(non_null(:date)))
  end

  input_object :ltree_filter_input do
    field(:match, :string)
  end

  node interface do
    resolve_type(fn
      %EntryType{}, _ -> :entry_type
      %Taxonomy{}, _ -> :taxonomy
      %Taxon{}, _ -> :taxon
      %Entry{}, _ -> :entry
      %Field{}, _ -> :field
      %FieldValue{}, _ -> :field_value
      %Route{}, _ -> :route
      %Form{}, _ -> :form
      %ConfigItem{}, _ -> :config_item
      _, _ -> nil
    end)
  end

  object :node_field do
    node field do
      resolve(fn
        %{type: :entry_type, id: id}, _ -> {:ok, Repo.get(EntryType, id)}
        %{type: :entry, id: id}, _ -> {:ok, Repo.get(Entry, id)}
        %{type: :taxonomy, id: id}, _ -> {:ok, Repo.get(Taxonomy, id)}
        %{type: :taxon, id: id}, _ -> {:ok, Repo.get(Taxon, id)}
        %{type: :field, id: id}, _ -> {:ok, Repo.get(Field, id)}
        %{type: :field_value, id: id}, _ -> {:ok, Repo.get(FieldValue, id)}
        %{type: :route, id: id}, _ -> {:ok, Repo.get(Route, id)}
        %{type: :form, id: id}, _ -> {:ok, Repo.get(Form, id)}
        %{type: :config_item, id: id}, _ -> {:ok, Repo.get(ConfigItem, id)}
      end)
    end
  end
end
