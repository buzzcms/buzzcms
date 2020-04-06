defmodule BuzzcmsWeb.EntryTypeFieldResolver do
  import Ecto.Query
  alias Ecto.Multi
  alias Buzzcms.Repo
  alias Buzzcms.Schema.{EntryType, EntryTypeField, Field}

  def create(
        %{data: data},
        %{context: %{role: "admin"}}
      ) do
    result = %EntryTypeField{} |> EntryTypeField.changeset(data) |> Repo.insert()

    case result do
      {:ok, _} ->
        {:ok,
         %{
           entry_type: Repo.get(EntryType, data.entry_type_id),
           field: Repo.get(Field, data.field_id)
         }}

      {:error, _} ->
        {:error, "Error occurs"}
    end
  end

  def create(_params, _info) do
    {:error, "Not authorized"}
  end

  def delete(
        %{data: data},
        %{context: %{role: "admin"}}
      ) do
    query =
      from(et in EntryTypeField,
        where: et.entry_type_id == ^data.entry_type_id and et.field_id == ^data.field_id
      )

    case Repo.delete_all(query) do
      {1, _} ->
        {:ok,
         %{
           entry_type: Repo.get(EntryType, data.entry_type_id),
           field: Repo.get(Field, data.field_id)
         }}

      {:error, _} ->
        {:error, "Error occurs"}
    end
  end

  def delete(_params, _info) do
    {:error, "Not authorized"}
  end

  def edit_position(
        %{entry_type_id: entry_type_id, field_ids: field_ids},
        %{context: %{role: "admin"}}
      )
      when is_list(field_ids) do
    multi = Multi.new()

    field_ids
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {field_id, position}, multi_acc ->
      Multi.run(
        multi_acc,
        {:entry_type_field, field_id},
        fn repo, _ ->
          result =
            from(etf in EntryTypeField,
              where: etf.field_id == ^field_id and etf.entry_type_id == ^entry_type_id,
              update: [set: [position: ^position]]
            )
            |> repo.update_all([])

          {:ok, result}
        end
      )
    end)
    |> Repo.transaction()

    order_query = from c in EntryTypeField, order_by: c.position
    {:ok, %{entry_type: Repo.get(EntryType, entry_type_id, preload: [fields: order_query])}}
  end
end
