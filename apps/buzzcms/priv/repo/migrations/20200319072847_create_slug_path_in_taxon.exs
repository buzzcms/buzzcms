defmodule Buzzcms.Repo.Migrations.CreateSlugPathInTaxon do
  use Buzzcms.Migration

  def up do
    alter table(:taxon) do
      add :slug_path, :ltree
    end

    create index(:taxon, [:path], using: "GIST")
    create index(:taxon, [:slug_path], using: "GIST")

    execute """
    CREATE OR REPLACE FUNCTION update_taxon_hierarchy()
    RETURNS TRIGGER
    AS $$
    DECLARE
    _parent_path ltree;
    _parent_slug_path ltree;
    BEGIN
    SELECT path into _parent_path from taxon where id = NEW.parent_id;
    SELECT slug_path into _parent_slug_path from taxon where id = NEW.parent_id;
    NEW.path =
      case when _parent_path is null
      then NEW.id::text::ltree
      else array_to_string(ARRAY[_parent_path::text, NEW.id::text], '.')::ltree
    end;
    NEW.slug_path =
      case when _parent_slug_path is null
      then REPLACE(NEW.slug, '-', '_')::ltree
      else array_to_string(ARRAY[_parent_slug_path::text, REPLACE(NEW.slug, '-', '_')], '.')::ltree
    end;
    IF NEW.path <@ OLD.path AND NEW.path <> OLD.path THEN
    raise 'Cannot update recursive tree';
    END IF;
    NEW.level = nlevel(NEW.path);
    NEW.is_root = (NEW.level = 1);
    RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;
    """
  end

  def down do
    execute """
    CREATE OR REPLACE FUNCTION update_taxon_hierarchy()
    RETURNS TRIGGER
    AS $$
    DECLARE
    _parent_path ltree;
    BEGIN
    SELECT path into _parent_path from taxon where id = NEW.parent_id;
    NEW.path =
      case when _parent_path = null
      then NEW.id::text::ltree
      else array_to_string(ARRAY[_parent_path::text, NEW.id::text], '.')::ltree
    end;
    IF NEW.path <@ OLD.path AND NEW.path <> OLD.path THEN
    raise 'Cannot update recursive tree';
    END IF;
    NEW.level = nlevel(NEW.path);
    NEW.is_root = (NEW.level = 1);
    RETURN NEW;
    END;
    $$
    LANGUAGE plpgsql;
    """

    drop index(:taxon, [:path])
    drop index(:taxon, [:slug_path])

    alter table(:taxon) do
      remove :slug_path, :ltree
    end
  end
end
