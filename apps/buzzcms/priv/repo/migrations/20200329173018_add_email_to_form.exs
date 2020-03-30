defmodule Buzzcms.Repo.Migrations.AddEmailToForm do
  use Ecto.Migration

  def change do
    alter table(:form) do
      add :send_from_email, :string
      add :notify_emails, {:array, :string}, default: "{}"
      add :notify_template, :jsonb, default: "{}"
      add :thank_you_template, :jsonb, default: "{}"
    end
  end
end
