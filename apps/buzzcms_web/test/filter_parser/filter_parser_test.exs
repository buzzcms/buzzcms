defmodule FilterParser.FilterParserTest do
  use ExUnit.Case
  alias FilterParser.{NumberFilterInput, IdFilterInput}
  alias Buzzcms.Schema.{Entry, EntryTaxon}

  describe "Filter Parser" do
    @schema Entry
    @filter_definition [
      fields: [
        avg_rating: NumberFilterInput,
        taxon_id: IdFilterInput
      ],
      foreign_fields: [
        taxons_id: {EntryTaxon, [foreign_key: :entry_id, foreign_filter_field: :taxon_id]}
      ]
    ]

    test "empty" do
      exp = FilterParser.FilterParser.parse(@schema, %{}, @filter_definition)
      assert exp == Entry
    end

    test "1 filter item" do
      exp = FilterParser.FilterParser.parse(@schema, %{avg_rating: %{gt: 3}}, @filter_definition)

      assert inspect(exp) ==
               ~s/#Ecto.Query<from e0 in Buzzcms.Schema.Entry, where: e0.avg_rating > ^3>/
    end

    test "multi filter item" do
      filter = %{avg_rating: %{gt: 3, le: 5}, taxon_id: %{in: [1, 2]}}
      exp = FilterParser.FilterParser.parse(@schema, filter, @filter_definition)

      assert inspect(exp) ==
               ~s/#Ecto.Query<from e0 in Buzzcms.Schema.Entry, where: e0.avg_rating > ^3 and e0.taxon_id in ^[1, 2]>/
    end

    test "with foreign filter fields" do
      filter = %{avg_rating: %{gt: 3, le: 5}, taxons_id: %{in: [1, 2]}}
      exp = FilterParser.FilterParser.parse(@schema, filter, @filter_definition)

      assert inspect(exp) ==
               ~s/#Ecto.Query<from e0 in Buzzcms.Schema.Entry, join: e1 in Buzzcms.Schema.EntryTaxon, on: e0.id == e1.entry_id, where: e0.avg_rating > ^3, where: e0.taxon_id in ^[1, 2]>/
    end
  end
end
