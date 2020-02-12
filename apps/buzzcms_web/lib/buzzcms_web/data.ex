defmodule BuzzcmsWeb.Data do
  import Ecto.Query

  def data() do
    Dataloader.Ecto.new(Buzzcms.Repo, query: &query/2)
  end

  def query(queryable, params) do
    case params do
      %{order_by: order_by, select: select} ->
        atom_select = select |> Enum.map(&String.to_atom(&1))
        from record in queryable, order_by: ^order_by, select: ^atom_select

      _ ->
        queryable
    end
  end
end
