defmodule Buzzcms.Repo.Migrations.AddEmailToForm do
  use Buzzcms.Migration

  def change do
    alter table(:form) do
      add :email_sender_id, references(:email_sender), null: false
      add :notify_emails, {:array, :string}, default: "{}"
      add :notify_template, :jsonb, default: "{}"
      add :thank_you_template, :jsonb, default: "{}"
    end

    create_unique_contraint(:email_sender, [:email, :provider])
  end
end
