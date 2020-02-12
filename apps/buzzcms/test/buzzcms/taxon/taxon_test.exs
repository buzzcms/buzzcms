defmodule Buzzcms.TaxonTest do
  use Buzzcms.DataCase
  import Ecto.Query
  import Buzzcms.Factory

  alias Buzzcms.Repo
  alias Buzzcms.Schema.Taxon

  setup [:init]

  describe("taxon trigger") do
    test "correct path, level for root taxon", %{root_taxon_1: %{id: id}} do
      assert %{
               parent_id: nil,
               is_root: true,
               level: 1,
               created_at: %DateTime{},
               modified_at: %DateTime{},
               path: %EctoLtree.LabelTree{labels: [_id]}
             } = Repo.get(Taxon, id)
    end

    test "correct path, level for non root taxon", %{root_taxon_1: %{id: id}} do
      assert %{
               id: child_id,
               parent_id: parent_id,
               is_root: false,
               level: 2,
               created_at: %DateTime{},
               modified_at: %DateTime{},
               path: %EctoLtree.LabelTree{labels: [id_text, child_id_text]}
             } = Repo.one(from t in Taxon, where: t.parent_id == ^id, limit: 1)

      assert to_string(id) == id_text
      assert to_string(child_id) == child_id_text
      assert parent_id == id
    end

    test "change parent_id", %{root_taxon_1: old_root_taxon, root_taxon_2: new_root_taxon} do
      %{id: id} =
        Repo.one(from t in Taxon, where: t.parent_id == ^old_root_taxon.id, limit: 1)
        |> Taxon.changeset(%{parent_id: new_root_taxon.id})
        |> Repo.update!()

      assert %{
               id: child_id,
               parent_id: parent_id,
               path: %EctoLtree.LabelTree{labels: labels}
             } = Repo.get!(Taxon, id)

      assert labels == ["#{new_root_taxon.id}", "#{child_id}"]
      assert parent_id == new_root_taxon.id
    end

    test "change parent_id will update all descendants path", %{
      root_taxon_1: root_taxon_1,
      root_taxon_2: root_taxon_2
    } do
      # Move taxon 1 to be children of taxon 2
      root_taxon_1
      |> Taxon.changeset(%{parent_id: root_taxon_2.id})
      |> Repo.update!()

      # Assert taxon_1 path
      %{is_root: false, path: %EctoLtree.LabelTree{labels: labels}} =
        Repo.get!(Taxon, root_taxon_1.id)

      assert labels == ["#{root_taxon_2.id}", "#{root_taxon_1.id}"]

      # Assert child taxon
      descentants_taxons = Repo.all(from t in Taxon, where: t.parent_id == ^root_taxon_1.id)

      descentants_taxons
      |> Enum.each(fn %{id: id, is_root: false, path: %EctoLtree.LabelTree{labels: labels}} ->
        assert labels == ["#{root_taxon_2.id}", "#{root_taxon_1.id}", "#{id}"]
      end)
    end
  end

  test "move taxon to root", %{root_taxon_1: root_taxon_1} do
    %{id: id} =
      Repo.one(from t in Taxon, where: t.parent_id == ^root_taxon_1.id, limit: 1)
      |> Taxon.changeset(%{parent_id: nil})
      |> Repo.update!()

    assert %{is_root: true, path: %EctoLtree.LabelTree{labels: labels}} = Repo.get!(Taxon, id)
    assert labels == ["#{id}"]
  end

  defp init(_context) do
    %{id: taxonomy_id} = insert(:taxonomy)
    root_taxon_1 = insert(:taxon, %{taxonomy_id: taxonomy_id})
    root_taxon_2 = insert(:taxon, %{taxonomy_id: taxonomy_id})

    children_taxons =
      insert_list(5, :taxon, %{taxonomy_id: taxonomy_id, parent_id: root_taxon_1.id})

    {:ok,
     root_taxon_1: root_taxon_1, root_taxon_2: root_taxon_2, children_taxons: children_taxons}
  end
end
