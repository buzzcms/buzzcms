defmodule Buzzcms.FilterParserTest do
  use Buzzcms.DataCase
  alias Buzzcms.FilterParser

  @filter_definition [
    {:slug, :string_filter_input},
    {:title, :string_filter_input},
    {:state, :string_filter_input},
    {:taxon_id, :id},
    {:entry_type_id, :id},
    {:taxon, :ref_filter_input},
    {:list_price, :float_filter_input},
    {:published_at, :date_filter_input}
  ]

  @filter_1 %{
    slug: %{eq: "hello"},
    title: %{ilike: "%xxx"},
    state: %{neq: "published"},
    published_at: %{gte: ~D[2020-01-01]},
    taxon_id: 1
  }

  @filter_2 %{
    state: %{in: ["published", "archive"]},
    # taxon: %{slug: "cat-01", taxonomy: "category"},
    entry_type_id: 1,
    list_price: %{gt: 10, lt: 3.2}
  }

  test "parse filter 1" do
    # TODO: Evaluate
    FilterParser.parse(@filter_1, @filter_definition)
  end

  test "parse filter 2" do
    # TODO: Evaluate
    FilterParser.parse(@filter_2, @filter_definition)
  end
end
