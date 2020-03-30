defmodule Buzzcms.Repo.Migrations.AddProfile do
  use Buzzcms.Migration

  def change do
    alter table(:user) do
      add :avatar, :string
      add :bio, :text
      add :website, :string
    end
  end
end
