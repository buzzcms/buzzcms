defmodule FilterParser.IdInputFilterTest do
  use ExUnit.Case

  alias FilterParser.ItemParser
  alias FilterParser.IdFilterInput

  describe "Id Filter" do
    test "eq" do
      exp = ItemParser.parse(%IdFilterInput{eq: 1}, :taxon_id, [])
      assert inspect(exp) == ~s/dynamic([p], p.taxon_id == ^1)/
    end

    test "neq" do
      exp = ItemParser.parse(%IdFilterInput{neq: 1}, :taxon_id, [])
      assert inspect(exp) == ~s/dynamic([p], p.taxon_id != ^1)/
    end

    test "in" do
      exp = ItemParser.parse(%IdFilterInput{in: [1, 2]}, :taxon_id, [])
      assert inspect(exp) == ~s/dynamic([p], p.taxon_id in ^[1, 2])/
    end

    test "nin" do
      exp = ItemParser.parse(%IdFilterInput{nin: [1, 2]}, :taxon_id, [])
      assert inspect(exp) == ~s/dynamic([p], p.taxon_id not in ^[1, 2])/
    end
  end
end
