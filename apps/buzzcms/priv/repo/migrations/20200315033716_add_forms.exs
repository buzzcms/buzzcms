defmodule Buzzcms.Repo.Migrations.AddForms do
  use Buzzcms.Migration

  def change do
    create table(:form) do
      add :code, :string, null: false
      add :display_name, :string, null: false
      add :note, :string
      add :data, :jsonb, default: "{}", null: false
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:form, [:code])

    create table(:subscriber) do
      add :email, :string
      add :phone, :string
      add :name, :string
      add :form_id, references(:form), null: false
      add :labels, :jsonb, default: "{}", null: false
      add :data, :jsonb, default: "{}", null: false
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create index(:subscriber, [:form_id])
  end
end
