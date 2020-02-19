defmodule FilterParser.NumberInputFilterTest do
  use ExUnit.Case

  alias FilterParser.ItemParser
  alias FilterParser.NumberFilterInput

  describe "Number Filter" do
    test "empty" do
      exp = ItemParser.parse(%NumberFilterInput{}, :avg_rating, [])
      assert exp == nil
    end

    test "eq" do
      exp = ItemParser.parse(%NumberFilterInput{eq: 1}, :avg_rating, [])
      assert inspect(exp) == ~s/dynamic([p], p.avg_rating == ^1)/
    end

    test "gt" do
      exp = ItemParser.parse(%NumberFilterInput{gt: 1}, :avg_rating, [])
      assert inspect(exp) == ~s/dynamic([p], p.avg_rating > ^1)/
    end

    test "lt" do
      exp = ItemParser.parse(%NumberFilterInput{lt: 1}, :avg_rating, [])
      assert inspect(exp) == ~s/dynamic([p], p.avg_rating < ^1)/
    end

    test "multiple condition" do
      exp = ItemParser.parse(%NumberFilterInput{gte: 1, lte: 3}, :avg_rating, [])
      assert inspect(exp) == ~s/dynamic([p], p.avg_rating >= ^1 and p.avg_rating <= ^3)/
    end
  end
end
