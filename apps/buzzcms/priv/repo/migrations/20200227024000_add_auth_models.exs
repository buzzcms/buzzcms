defmodule Buzzcms.Repo.Migrations.AddAuthModels do
  use Ecto.Migration

  def change do
    # Token
    create table(:token) do
      add :user_id, references(:user, type: :uuid), primary_key: true, null: false
      add :type, :string, null: false
      add :token, :text, null: false, default: fragment("uuid_generate_v4()")
      add :expired_at, :utc_datetime, null: false, default: fragment("now() + interval '1h'")
      add :is_used, :boolean, null: false, default: false
    end

    create index(:token, [:user_id])
    create index(:token, [:token])
    create constraint(:token, :token_type, check: "type in ('verify_email', 'reset_password')")

    # Email sender
    create table(:email_sender) do
      add :email, :string, null: false
      add :name, :string, null: false
      add :is_verified, :boolean, null: false, default: false
      add :provider, :string, null: false, default: "SES"
    end

    create index(:email_sender, [:email])

    # Email template
    create table(:email_template) do
      add :email_sender_id, references(:email_sender)
      add :type, :string, null: false
      add :subject, :string, null: false
      add :html, :string, null: false
      add :text, :string, null: false
      add :link, :string, null: false
    end

    create constraint(:email_template, :email_template_type,
             check: "type in ('verify_email', 'reset_password')"
           )
  end
end
