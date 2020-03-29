defmodule Buzzcms.DataImporter do
  import Ecto.Query
  alias Buzzcms.Repo

  alias Buzzcms.EmbeddedSchema.{
    ImageItem,
    Seo
  }

  alias Buzzcms.Schema.{
    Entry,
    EntryBooleanValue,
    EntryDecimalValue,
    EntryIntegerValue,
    EntryJsonValue,
    EntrySelectValue,
    EntryTaxon,
    EntryType,
    EntryTypeField,
    EntryTypeTaxonomy,
    Field,
    FieldValue,
    Form,
    Taxon,
    Taxonomy
  }

  def import_from_dir(dir) when is_bitstring(dir) do
    taxonomies = YamlElixir.read_from_file!(Path.join(dir, "01_taxonomy.yml"))
    fields = YamlElixir.read_from_file!(Path.join(dir, "02_field.yml"))
    entry_types = YamlElixir.read_from_file!(Path.join(dir, "03_entry_type.yml"))
    taxons = YamlElixir.read_from_file!(Path.join(dir, "04_taxon.yml"))
    entries = YamlElixir.read_from_file!(Path.join(dir, "05_entry.yml"))
    forms = YamlElixir.read_from_file!(Path.join(dir, "06_form.yml"))

    # Taxonomies
    Repo.insert_all(
      Taxonomy,
      taxonomies
      |> Enum.map(&%{code: &1["code"], display_name: &1["display_name"]}),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert taxonomy")

    taxonomies_map =
      Repo.all(Taxonomy)
      |> Enum.reduce(%{}, fn %{id: id, code: code}, acc -> Map.put(acc, code, id) end)

    # Fields
    Repo.insert_all(
      Field,
      fields
      |> Enum.map(
        &%{
          code: &1["code"],
          display_name: &1["display_name"],
          type: &1["type"],
          position: &1["position"]
        }
      ),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert field")

    fields_map =
      Repo.all(Field)
      |> Enum.reduce(%{}, fn %{id: id, code: code}, acc -> Map.put(acc, code, id) end)

    # Field Values
    field_values =
      fields
      |> Enum.map(&get_values_from_field(&1, fields_map))
      |> List.flatten()

    Repo.insert_all(FieldValue, field_values, on_conflict: :nothing)
    |> IO.inspect(label: "Insert field value")

    field_values_map =
      Repo.all(
        from fv in FieldValue,
          join: f in Field,
          on: fv.field_id == f.id,
          select: %{id: fv.id, code: fv.code, field_id: f.id, field_code: f.code}
      )
      |> Enum.reduce(%{}, fn %{id: id, code: code, field_id: field_id, field_code: field_code},
                             acc ->
        Map.put(acc, "#{field_code}:#{code}", %{id: id, field_id: field_id})
      end)

    # Entry Types
    Repo.insert_all(
      EntryType,
      entry_types
      |> Enum.map(&%{code: &1["code"], display_name: &1["display_name"]}),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_type")

    entry_types_map =
      Repo.all(EntryType)
      |> Enum.reduce(%{}, fn %{id: id, code: code}, acc -> Map.put(acc, code, id) end)

    # Entry Type - Taxonomies
    Repo.insert_all(
      EntryTypeTaxonomy,
      entry_types
      |> Enum.map(
        &get_entry_type_taxonomies(&1, %{
          entry_types_map: entry_types_map,
          taxonomies_map: taxonomies_map
        })
      )
      |> List.flatten(),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_type_taxonomy")

    # Entry Type - Fields
    Repo.insert_all(
      EntryTypeField,
      entry_types
      |> Enum.map(
        &get_entry_type_fields(&1, %{
          entry_types_map: entry_types_map,
          fields_map: fields_map
        })
      )
      |> List.flatten(),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_type_field")

    # Taxons
    Repo.insert_all(
      Taxon,
      taxons
      |> Enum.map(fn %{"slug" => slug, "title" => title, "taxonomy" => taxonomy_code} = taxon ->
        %{
          slug: slug,
          title: title,
          taxonomy_id: taxonomies_map[taxonomy_code],
          featured: taxon["featured"] || false,
          state: taxon["state"] || "draft"
        }
      end),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert taxon")

    taxons_map =
      Repo.all(
        from t in Taxon,
          join: tx in Taxonomy,
          on: t.taxonomy_id == tx.id,
          select: %{id: t.id, slug: t.slug, taxonomy_code: tx.code}
      )
      |> Enum.reduce(%{}, fn %{id: id, slug: slug, taxonomy_code: taxonomy_code}, acc ->
        Map.put(acc, "#{taxonomy_code}:#{slug}", id)
      end)

    # Update taxon parent
    taxons
    |> Enum.filter(&Map.has_key?(&1, "parent"))
    |> Enum.each(fn %{"slug" => slug, "taxonomy" => taxonomy, "parent" => parent} ->
      id = taxons_map["#{taxonomy}:#{slug}"]
      parent_id = taxons_map["#{taxonomy}:#{parent}"]

      Repo.get!(Taxon, id)
      |> Taxon.changeset(%{parent_id: parent_id})
      |> Repo.update!()
    end)

    # Entries
    Repo.insert_all(
      Entry,
      entries
      |> Enum.map(fn %{
                       "slug" => slug,
                       "title" => title,
                       "entry_type" => entry_type_code
                     } = entry ->
        %{
          slug: slug,
          title: title,
          entry_type_id: entry_types_map[entry_type_code],
          featured: entry["featured"] || false,
          tags: entry["tags"],
          image: entry["image"],
          images:
            (entry["images"] || [])
            |> Enum.map(
              &struct(ImageItem, %{
                id: &1["id"],
                caption: &1["caption"]
              })
            ),
          seo:
            struct(Seo, %{
              title: get_in(entry, ["seo", "title"]),
              description: get_in(entry, ["seo", "description"]),
              keywords: get_in(entry, ["seo", "keywords"])
            }),
          state: entry["state"] || "draft"
        }
      end),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry")

    entries_map =
      Repo.all(
        from e in Entry,
          join: et in EntryType,
          on: e.entry_type_id == et.id,
          select: %{id: e.id, slug: e.slug, entry_type_code: et.code}
      )
      |> Enum.reduce(%{}, fn %{id: id, slug: slug, entry_type_code: entry_type_code}, acc ->
        Map.put(acc, "#{entry_type_code}:#{slug}", id)
      end)

    # Entry Taxons
    Repo.insert_all(
      EntryTaxon,
      entries
      |> Enum.map(&get_entry_taxons(&1, %{entries_map: entries_map, taxons_map: taxons_map}))
      |> List.flatten(),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_taxon")

    # Entry Select Values
    Repo.insert_all(
      EntrySelectValue,
      entries
      |> Enum.map(
        &get_entry_select_values(&1, %{
          entries_map: entries_map,
          field_values_map: field_values_map
        })
      )
      |> List.flatten(),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_select_value (single)")

    # Entry Multi Select Values
    Repo.insert_all(
      EntrySelectValue,
      entries
      |> Enum.map(
        &get_entry_multi_select_values(&1, %{
          entries_map: entries_map,
          field_values_map: field_values_map
        })
      )
      |> List.flatten(),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_select_value (multiple)")

    # Entry Boolean Values
    Repo.insert_all(
      EntryBooleanValue,
      entries
      |> Enum.map(
        &get_entry_field_values(&1 |> Map.put("values", &1["boolean_values"]), %{
          entries_map: entries_map,
          fields_map: fields_map
        })
      )
      |> List.flatten(),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_boolean_value")

    # Entry Integer Values
    Repo.insert_all(
      EntryIntegerValue,
      entries
      |> Enum.map(
        &get_entry_field_values(&1 |> Map.put("values", &1["integer_values"]), %{
          entries_map: entries_map,
          fields_map: fields_map
        })
      )
      |> List.flatten(),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_integer_value")

    # Entry Json Values
    Repo.insert_all(
      EntryJsonValue,
      entries
      |> Enum.map(
        &get_entry_field_values(&1 |> Map.put("values", &1["json_values"]), %{
          entries_map: entries_map,
          fields_map: fields_map
        })
      )
      |> List.flatten(),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_json_value")

    # Entry Decimal Values
    Repo.insert_all(
      EntryDecimalValue,
      entries
      |> Enum.map(
        &get_entry_field_values(&1 |> Map.put("values", &1["decimal_values"]), %{
          entries_map: entries_map,
          fields_map: fields_map
        })
      )
      |> List.flatten(),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert entry_decimal_value")

    # Forms
    Repo.insert_all(
      Form,
      forms
      |> Enum.map(&%{code: &1["code"], display_name: &1["display_name"]}),
      on_conflict: :nothing
    )
    |> IO.inspect(label: "Insert form")
  end

  defp get_values_from_field(%{"values" => values, "code" => field}, fields_map)
       when is_list(values) do
    values
    |> Enum.map(fn %{"code" => code, "display_name" => display_name} ->
      %{code: code, display_name: display_name, description: "", field_id: fields_map[field]}
    end)
  end

  defp get_values_from_field(_, _), do: []

  defp get_entry_type_taxonomies(%{"code" => entry_type_code, "taxonomies" => taxonomies}, %{
         taxonomies_map: taxonomies_map,
         entry_types_map: entry_types_map
       })
       when is_list(taxonomies) do
    taxonomies
    |> Enum.map(fn taxonomy_code ->
      %{
        entry_type_id: entry_types_map[entry_type_code],
        taxonomy_id: taxonomies_map[taxonomy_code]
      }
    end)
  end

  defp get_entry_type_taxonomies(_, _), do: []

  defp get_entry_type_fields(%{"code" => entry_type_code, "fields" => fields}, %{
         fields_map: fields_map,
         entry_types_map: entry_types_map
       })
       when is_list(fields) do
    fields
    |> Enum.map(fn field_code ->
      %{
        entry_type_id: entry_types_map[entry_type_code],
        field_id: fields_map[field_code]
      }
    end)
  end

  defp get_entry_type_fields(_, _), do: []

  defp get_entry_taxons(
         %{"slug" => entry_slug, "entry_type" => entry_type, "taxons" => taxons},
         %{
           entries_map: entries_map,
           taxons_map: taxons_map
         }
       )
       when is_list(taxons) do
    taxons
    |> Enum.map(fn %{"slug" => slug, "taxonomy" => taxonomy} ->
      %{
        entry_id: entries_map["#{entry_type}:#{entry_slug}"],
        taxon_id: taxons_map["#{taxonomy}:#{slug}"]
      }
    end)
  end

  defp get_entry_taxons(_, _), do: []

  defp get_entry_multi_select_values(
         %{
           "slug" => entry_slug,
           "entry_type" => entry_type,
           "multi_select_values" => multi_select_values
         },
         %{
           entries_map: entries_map,
           field_values_map: field_values_map
         }
       )
       when is_list(multi_select_values) do
    multi_select_values
    |> Enum.map(fn %{"field" => field, "value" => value_list} ->
      value_list
      |> Enum.map(fn value ->
        %{id: field_value_id, field_id: field_id} = field_values_map["#{field}:#{value}"]

        %{
          entry_id: entries_map["#{entry_type}:#{entry_slug}"],
          field_value_id: field_value_id,
          field_id: field_id
        }
      end)
    end)
  end

  defp get_entry_multi_select_values(_, _), do: []

  defp get_entry_select_values(
         %{
           "slug" => entry_slug,
           "entry_type" => entry_type,
           "select_values" => select_values
         },
         %{
           entries_map: entries_map,
           field_values_map: field_values_map
         }
       )
       when is_list(select_values) do
    select_values
    |> Enum.map(fn %{"field" => field, "value" => value} ->
      %{id: field_value_id, field_id: field_id} = field_values_map["#{field}:#{value}"]

      %{
        entry_id: entries_map["#{entry_type}:#{entry_slug}"],
        field_value_id: field_value_id,
        field_id: field_id
      }
    end)
  end

  defp get_entry_select_values(_, _), do: []

  # Use for any field values except select, multi_select value
  defp get_entry_field_values(
         %{
           "slug" => entry_slug,
           "entry_type" => entry_type,
           "values" => values
         },
         %{
           entries_map: entries_map,
           fields_map: fields_map
         }
       )
       when is_list(values) do
    values
    |> Enum.map(fn %{"field" => field_code, "value" => value} ->
      %{
        entry_id: entries_map["#{entry_type}:#{entry_slug}"],
        field_id: fields_map[field_code],
        value: value
      }
    end)
  end

  defp get_entry_field_values(_, _), do: []
end
