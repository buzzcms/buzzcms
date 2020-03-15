defmodule Buzzcms.Repo.Migrations.AddConfigItem do
  use Buzzcms.Migration

  def change do
    create table(:config_item) do
      add :code, :string, null: false
      add :display_name, :string, null: false
      add :type, :string, null: false
      add :note, :string
      add :data, :jsonb, default: "{}", null: false
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:config_item, [:code])
    create index(:config_item, [:type])
  end
end
