defmodule BuzzcmsWeb.Data do
  def data() do
    Dataloader.Ecto.new(Buzzcms.Repo, query: &query/2)
  end

  def query(queryable, params) do
    case params do
      %{fields: fields, filter: filter} ->
        queryable |> FilterParser.FilterParser.parse(filter, fields: fields)

      _ ->
        queryable
    end
  end
end
