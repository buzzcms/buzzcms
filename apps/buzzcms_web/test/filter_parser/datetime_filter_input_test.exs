defmodule FilterParser.DateTimeInputFilterTest do
  use ExUnit.Case

  alias FilterParser.ItemParser
  alias FilterParser.DateTimeFilterInput

  describe "DateTime Filter" do
    test "eq" do
      exp = ItemParser.parse(%DateTimeFilterInput{eq: ~D[2018-08-20]}, :published_at, [])

      assert inspect(exp) == ~s/dynamic([p], p.published_at == ^~D[2018-08-20])/
    end

    test "gt" do
      exp = ItemParser.parse(%DateTimeFilterInput{gt: ~D[2018-08-20]}, :published_at, [])
      assert inspect(exp) == ~s/dynamic([p], p.published_at > ^~D[2018-08-20])/
    end

    test "lt" do
      exp = ItemParser.parse(%DateTimeFilterInput{lt: ~D[2018-08-20]}, :published_at, [])
      assert inspect(exp) == ~s/dynamic([p], p.published_at < ^~D[2018-08-20])/
    end

    test "multiple condition" do
      exp =
        ItemParser.parse(
          %DateTimeFilterInput{gt: ~D[2018-08-20], lte: ~D[2020-08-20]},
          :published_at,
          []
        )

      assert inspect(exp) ==
               ~s/dynamic([p], p.published_at > ^~D[2018-08-20] and p.published_at <= ^~D[2020-08-20])/
    end
  end
end
