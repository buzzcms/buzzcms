defmodule BuzzcmsWeb.ParseIDsHelper do
  def get_ids(key) do
    [eq: key, in: key, neq: key]
  end
end
