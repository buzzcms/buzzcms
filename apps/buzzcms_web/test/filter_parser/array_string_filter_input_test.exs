defmodule FilterParser.ArrayStringFilterInputTest do
  use ExUnit.Case

  alias FilterParser.ItemParser
  alias FilterParser.ArrayStringFilterInput

  describe "Id Filter" do
    test "all" do
      exp = ItemParser.parse(%ArrayStringFilterInput{all: ["a", "b"]}, :tags, [])
      assert inspect(exp) == ~s/dynamic([p], fragment("? @> ?", p.tags, ^["a", "b"]))/
    end

    test "any" do
      exp = ItemParser.parse(%ArrayStringFilterInput{any: ["a", "b"]}, :tags, [])
      assert inspect(exp) == ~s/dynamic([p], fragment("? && ?", p.tags, ^["a", "b"]))/
    end
  end
end
