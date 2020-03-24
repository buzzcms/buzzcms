defmodule Buzzcms.Repo.Migrations.AddTaxonBreadcrumbs do
  use Buzzcms.Migration

  def change do
    alter table(:taxon) do
      add :breadcrumbs, :jsonb, default: "[]"
    end

    create_function__make_breadcrumbs_after_update_taxon_path()

    create_trigger(
      name: "taxon_update_breadcrumbs",
      table: "taxon",
      trigger: "BEFORE UPDATE OF parent_id",
      function: "make_breadcrumbs_after_update_taxon_path"
    )
  end

  defp create_function__make_breadcrumbs_after_update_taxon_path() do
    execute """
            CREATE FUNCTION make_breadcrumbs_after_update_taxon_path()
            RETURNS TRIGGER
            AS $$
            BEGIN
            NEW.breadcrumbs = (SELECT json_agg(t) FROM (
              SELECT
                  taxon.id, slug, title,
                json_build_object('id', tx.id, 'code', tx.code, 'display_name', tx.display_name) as taxonomy
              FROM taxon
              INNER JOIN taxonomy tx ON taxon.taxonomy_id = tx.id
              ORDER BY t.level
              WHERE taxon.id IN
                (SELECT unnest(string_to_array(PATH::text, '.')::int[])
                FROM taxon
                WHERE "id" = NEW.id)
            ) t);
            RETURN NEW;
            END;
            $$
            LANGUAGE plpgsql;
            """,
            "DROP FUNCTION make_breadcrumbs_after_update_taxon_path"
  end
end
