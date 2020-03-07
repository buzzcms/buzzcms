defmodule Buzzcms.Repo.Migrations.AddProducts do
  use Buzzcms.Migration

  def change do
    alter table(:entry_type) do
      add :is_product, :boolean, default: false, null: false
    end

    create table(:product) do
      add :entry_id, references(:entry), null: false
      add :available_at, :utc_datetime, null: false, default: fragment("now()")
      add :discontinue_at, :utc_datetime
    end

    create_unique_contraint(:product, [:entry_id])

    create_function__create_products_when_update_entry_type()
    create_function__create_product_when_create_entry()
    create_function__create_master_variant_when_create_product()

    create_trigger(
      name: "entry_type_after_update",
      table: "entry_type",
      trigger: "AFTER UPDATE",
      function: "create_products_when_update_entry_type"
    )

    create_trigger(
      name: "entry_after_insert",
      table: "entry",
      trigger: "AFTER INSERT",
      function: "create_product_when_create_entry"
    )

    create_trigger(
      name: "product_after_insert",
      table: "product",
      trigger: "AFTER INSERT",
      function: "create_master_variant_when_create_product"
    )

    create table(:option_type) do
      add :code, :string, null: false
      add :display_name, :string, null: false
      add :product_id, references(:product), null: false
      add :position, :integer, default: 0
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:option_type, [:product_id, :code])
    create index(:option_type, [:product_id])

    create table(:option_value) do
      add :code, :string, null: false
      add :display_name, :string, null: false
      add :option_type_id, references(:option_type), null: false
      add :image, :string
      add :position, :integer, default: 0
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:option_value, [:option_type_id, :code])
    create index(:option_value, [:option_type_id])

    create table(:variant) do
      add :sku, :string
      add :product_id, references(:product), null: false
      add :key, :string
      add :is_master, :boolean, default: false
      add :image, :string
      add :position, :integer, default: 0
      add :list_price, :decimal, precision: 14, scale: 2
      add :sale_price, :decimal, precision: 14, scale: 2
      add :weight, :decimal, precision: 14, scale: 2
      add :height, :decimal, precision: 14, scale: 2
      add :width, :decimal, precision: 14, scale: 2
      add :depth, :decimal, precision: 14, scale: 2
      add :track_inventory, :boolean, default: true, null: false
      add :is_valid, :boolean, default: false, null: false
    end

    create_unique_contraint(:variant, [:sku])
    create_unique_contraint(:variant, [:key])
    create index(:variant, [:product_id])
    create index(:variant, [:list_price])
    create index(:variant, [:sale_price])

    create table(:variant_option_value) do
      add :sku, :string
      add :variant_id, references(:variant), null: false
      add :option_value_id, references(:option_value), null: false
    end

    create_unique_contraint(:variant_option_value, [:variant_id, :option_value_id])
    create index(:variant_option_value, [:variant_id])
  end

  @doc """
  If an entry_type is update to is_product = true, add relevant product that all entries belong to that entry_type
  """
  def create_function__create_products_when_update_entry_type do
    execute(
      """
      CREATE FUNCTION create_products_when_update_entry_type()
      RETURNS TRIGGER
      AS $$
      BEGIN
      INSERT INTO product(entry_id)
      SELECT id FROM entry
      WHERE entry_type_id = NEW.id AND NEW.is_product = true
      ON CONFLICT DO NOTHING;
      RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      """,
      "DROP FUNCTION create_products_when_update_entry_type"
    )
  end

  @doc """
  When create new entry, if entry_type is product, create relevant product of the created entry
  """
  def create_function__create_product_when_create_entry do
    execute(
      """
      CREATE FUNCTION create_product_when_create_entry()
      RETURNS TRIGGER
      AS $$
      BEGIN
        IF EXISTS (SELECT * from entry_type where id = NEW.entry_type_id and is_product = true) THEN
          INSERT INTO product (entry_id) VALUES (NEW.id);
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      """,
      "DROP FUNCTION create_product_when_create_entry"
    )
  end

  @doc """
  When create new product, create a relevant master variant
  """
  def create_function__create_master_variant_when_create_product do
    execute(
      """
      CREATE FUNCTION create_master_variant_when_create_product ()
      RETURNS TRIGGER
      AS $$
      BEGIN
      INSERT INTO variant (product_id, is_master) VALUES (NEW.id, true);
      RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      """,
      "DROP FUNCTION create_master_variant_when_create_product"
    )
  end
end
