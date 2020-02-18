defmodule FilterParser.Helper do
  import Ecto.Query

  def join_exp(acc, exp) do
    case acc do
      nil -> exp
      _ -> dynamic(^acc and ^exp)
    end
  end
end
