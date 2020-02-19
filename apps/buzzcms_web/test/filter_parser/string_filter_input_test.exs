defmodule FilterParser.StringInputFilterTest do
  use ExUnit.Case

  alias FilterParser.ItemParser
  alias FilterParser.StringFilterInput

  describe "String Filter" do
    test "eq" do
      exp = ItemParser.parse(%StringFilterInput{eq: "lorem"}, :name, [])
      assert inspect(exp) == ~s/dynamic([p], p.name == ^"lorem")/
    end

    test "gt" do
      exp = ItemParser.parse(%StringFilterInput{neq: "lorem"}, :name, [])
      assert inspect(exp) == ~s/dynamic([p], p.name != ^"lorem")/
    end

    test "like" do
      exp = ItemParser.parse(%StringFilterInput{like: "lorem"}, :name, [])
      assert inspect(exp) == ~s/dynamic([p], like(p.name, ^"lorem"))/
    end

    test "ilike" do
      exp = ItemParser.parse(%StringFilterInput{ilike: "lorem"}, :name, [])
      assert inspect(exp) == ~s/dynamic([p], ilike(p.name, ^"lorem"))/
    end

    test "in" do
      exp = ItemParser.parse(%StringFilterInput{in: ["lorem", "ipsum"]}, :name, [])
      assert inspect(exp) == ~s/dynamic([p], p.name in ^["lorem", "ipsum"])/
    end
  end
end
