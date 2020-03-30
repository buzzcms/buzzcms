defmodule Buzzcms.Repo.Migrations.AddEmailToForm do
  use Buzzcms.Migration

  def change do
    # Add index to email_sender
    alter table(:email_sender) do
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:email_sender, [:email, :provider])

    # Refine email template
    drop constraint(:email_template, :email_template_type)

    alter table(:email_template) do
      add :is_system, :boolean, null: false, default: false
      remove :type
      remove :link
      add :code, :string, null: false
      add :note, :string
      add :created_at, :utc_datetime, null: false, default: fragment("now()")
    end

    create_unique_contraint(:email_template, [:code])

    alter table(:form) do
      add :notify_emails, {:array, :string}, default: "{}"
      add :notify_template_id, references(:email_template)
      add :thank_you_template_id, references(:email_template)
    end
  end
end
