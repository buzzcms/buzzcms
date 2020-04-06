defmodule Buzzcms.Repo.Migrations.AddEntryTypeConfig do
  use Ecto.Migration

  def change do
    alter table(:entry_type) do
      add :config, :jsonb, default: "{}", null: false
    end
  end
end
