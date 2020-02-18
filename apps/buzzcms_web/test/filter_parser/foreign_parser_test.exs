defmodule FilterParser.ForeignParserTest do
  use ExUnit.Case
  alias Buzzcms.Schema.{Entry, EntryTaxon}

  describe "Foreign Filter Parser" do
    @foreign_fields [
      taxons_id: {EntryTaxon, [foreign_key: :entry_id, foreign_filter_field: :taxon_id]}
    ]

    test "eq" do
      exp = FilterParser.ForeignFilterInput.parse(Entry, %{taxons_id: %{eq: 1}}, @foreign_fields)

      assert inspect(exp) ==
               ~s/#Ecto.Query<from e0 in Buzzcms.Schema.Entry, join: e1 in Buzzcms.Schema.EntryTaxon, on: e0.id == e1.entry_id, where: e0.taxon_id == ^1>/
    end
  end
end
