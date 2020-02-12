defmodule Buzzcms.Repo.Migrations.Initialize do
  use Buzzcms.Migration

  def change do
    create_extension([:ltree, :"uuid-ossp"])
    create_function__update_modified_at()

    # Auth Provider
    create table(:auth_provider, primary_key: false) do
      add :value, :text, primary_key: true, null: false
      add :comment, :text
      add :is_default, :boolean, default: false
    end

    # Role
    create table(:role, primary_key: false) do
      add :value, :text, primary_key: true, null: false
      add :comment, :text
      add :is_default, :boolean, default: false
    end

    # User
    create table(:user, primary_key: false) do
      add :id, :uuid, default: fragment("uuid_generate_v4()"), primary_key: true, null: false
      add :email, :text, null: false
      add :display_name, :text, null: false
      add :nickname, :text
      add :password_hash, :text
      add :is_verified, :boolean, null: false, default: false
      add :auth_provider, references(:auth_provider, column: :value, type: :text), null: false
      add :role, references(:role, column: :value, type: :text), null: false
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
      add :modified_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:user, [:email, :auth_provider])
    create_unique_contraint(:user, [:nickname, :auth_provider])
  end
end
