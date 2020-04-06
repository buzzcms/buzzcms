defmodule BuzzcmsWeb.Data do
  alias FilterParser.FilterParser

  def data() do
    Dataloader.Ecto.new(Buzzcms.Repo, query: &query/2)
  end

  def query(queryable, opts) do
    params = Map.get(opts, :params)
    filter_definition = Map.get(opts, :filter_definition)
    make_query(queryable, filter_definition, params)
  end

  defp make_query(queryable, nil, _), do: queryable
  defp make_query(queryable, fd, %{filter: f = %{}}), do: queryable |> FilterParser.parse(f, fd)
  defp make_query(queryable, _, _), do: queryable
end
