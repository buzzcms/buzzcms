defmodule FilterParser.LtreeInputFilterTest do
  use ExUnit.Case

  alias FilterParser.ItemParser
  alias FilterParser.LtreeFilterInput

  describe "Ltree Filter" do
    test "empty" do
      exp = ItemParser.parse(%LtreeFilterInput{}, :path, [])
      assert exp == nil
    end

    test "match" do
      exp = ItemParser.parse(%LtreeFilterInput{match: "*.1.*"}, :path, [])
      assert inspect(exp) == ~s/dynamic([p], fragment("? ~ ?", p.path, ^"*.1.*"))/
    end
  end
end
