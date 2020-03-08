defmodule Buzzcms.Repo.Migrations.AddBasicModels do
  use Buzzcms.Migration

  @states ~w('draft' 'published' 'archive' 'trash')

  def change do
    # Route
    create table(:route) do
      add :name, :string, null: false
      add :pattern, :string, null: false
      add :heading, :jsonb, default: "{}", null: false
      add :data, :jsonb, default: "{}", null: false
      add :seo, :jsonb, default: "{}", null: false
    end

    create_unique_contraint(:route, [:name])

    # Image
    create table(:image, primary_key: false) do
      add :id, :string, primary_key: true
      add :remote_url, :string
      add :name, :string, null: false
      add :ext, :string
      add :mime, :string
      add :caption, :string
      add :width, :decimal, precision: 8, scale: 2
      add :height, :decimal, precision: 8, scale: 2
      add :size, :decimal, precision: 14, scale: 2
      add :status, :string, null: false, default: "ready"
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
      add :modified_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:image, [:remote_url])

    # Redirect
    create table(:redirect) do
      add :from, :string, null: false
      add :to, :string, null: false
      add :type, :integer, null: false, default: 302
      add :note, :string
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:redirect, [:from])
    create constraint(:redirect, :redirect_type, check: "type in (301, 302, 303, 307, 308)")

    # Entry type
    create table(:entry_type) do
      add :code, :string, null: false
      add :display_name, :string, null: false
      add :note, :string
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
      add :modified_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:entry_type, [:code])
    create_update_modified_at_trigger(:entry_type)

    # Taxonomy
    create table(:taxonomy) do
      add :code, :string, null: false
      add :display_name, :string, null: false
      add :note, :string
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
      add :modified_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:taxonomy, [:code])
    create_update_modified_at_trigger(:taxonomy)

    # Entry Type - Taxonomy
    create table(:entry_type_taxonomy, primary_key: false) do
      add :entry_type_id, references(:entry_type), primary_key: true, null: false
      add :taxonomy_id, references(:taxonomy), primary_key: true, null: false
      add :position, :integer, default: 0, null: false
    end

    # Taxon
    create table(:taxon) do
      create_entry_fields()
      add :entries_count, :integer
      add :parent_id, references(:taxon)
      add :is_root, :boolean
      add :path, :ltree
      add :level, :integer
      add :group, :string
      add :taxonomy_id, references(:taxonomy), null: false
    end

    create_unique_contraint(:taxon, [:nanoid])
    create_unique_contraint(:taxon, [:key])
    create index(:taxon, [:taxonomy_id])
    create index(:taxon, [:parent_id])
    create index(:taxon, [:group])
    create index(:taxon, ["created_at DESC"])
    create index(:taxon, ["modified_at DESC"])
    create index(:taxon, [:created_by_id])
    create index(:taxon, [:modified_by_id])
    create constraint(:taxon, :taxon_state, check: "state in (#{Enum.join(@states, ",")})")
    create_update_modified_at_trigger(:taxon)
    create_function__update_taxon_hierarchy()

    create_function__update_taxon_descendants()

    create_trigger(
      name: "taxon_update_hierarchy",
      table: "taxon",
      trigger: "BEFORE INSERT OR UPDATE",
      function: "update_taxon_hierarchy"
    )

    create_trigger(
      name: "taxon_update_descendants",
      table: "taxon",
      trigger: "AFTER UPDATE",
      function: "update_taxon_descendants"
    )

    # Entry
    create table(:entry) do
      create_entry_fields()
      add :entry_type_id, references(:entry_type), null: false
      add :taxon_id, references(:taxon)
      add :published_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:entry, [:nanoid])
    create_unique_contraint(:entry, [:key])
    create index(:entry, [:entry_type_id])
    create index(:entry, [:taxon_id])
    create index(:entry, ["created_at DESC"])
    create index(:entry, ["modified_at DESC"])
    create index(:entry, [:created_by_id])
    create index(:entry, [:modified_by_id])
    create constraint(:entry, :entry_state, check: "state in (#{Enum.join(@states, ",")})")
    create_update_modified_at_trigger(:entry)

    # Entry - Taxon
    create table(:entry_taxon, primary_key: false) do
      add :entry_id, references(:entry), primary_key: true, null: false
      add :taxon_id, references(:taxon), primary_key: true, null: false
      add :position, :integer, default: 0, null: false
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create index(:entry_taxon, [:entry_id])
    create index(:entry_taxon, [:taxon_id])

    # Related taxon
    create table(:related_taxon, primary_key: false) do
      add :source_id, references(:taxon), primary_key: true, null: false
      add :taxon_id, references(:taxon), primary_key: true, null: false
      add :position, :integer, default: 0, null: false
    end

    create index(:related_taxon, [:source_id])
    create index(:related_taxon, [:taxon_id])
  end

  defp create_entry_fields do
    add :nanoid, :string
    add :key, :string
    add :slug, :string, null: false
    add :title, :string, null: false
    add :subtitle, :string
    add :description, :string, null: false, default: ""
    add :body, :text, null: false, default: ""
    add :rich_text, {:array, :jsonb}
    add :featured, :boolean, default: false, null: false
    add :image, :string
    add :images, :jsonb, default: "[]"
    add :position, :integer, default: 0, null: false
    add :seo, :jsonb, default: "{}", null: false
    add :labels, :jsonb, default: "{}", null: false
    add :data, :jsonb, default: "{}", null: false
    add :state, :string, default: "draft", null: false
    add :created_at, :utc_datetime, null: false, default: fragment("now()")
    add :modified_at, :utc_datetime, null: false, default: fragment("now()")
    add :created_by_id, references(:user, type: :uuid)
    add :modified_by_id, references(:user, type: :uuid)
  end

  defp create_function__update_taxon_hierarchy() do
    execute """
            CREATE FUNCTION update_taxon_hierarchy()
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
            """,
            "DROP FUNCTION update_taxon_hierarchy"
  end

  defp create_function__update_taxon_descendants() do
    execute """
            CREATE FUNCTION update_taxon_descendants()
            RETURNS TRIGGER
            AS $$
            BEGIN
            UPDATE taxon
            SET parent_id = parent_id
            WHERE path <@ OLD.path AND path <> OLD.path;
            RETURN NEW;
            END;
            $$
            LANGUAGE plpgsql;
            """,
            "DROP FUNCTION update_taxon_descendants"
  end
end
