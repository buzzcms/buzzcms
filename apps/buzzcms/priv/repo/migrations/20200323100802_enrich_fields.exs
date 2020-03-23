defmodule Buzzcms.Repo.Migrations.EnrichFields do
  use Ecto.Migration

  def change do
    alter table(:entry) do
      add :tags, {:array, :text}, default: "{}"
    end

    alter table(:field_value) do
      add :image, :text
      add :color, :text
    end
  end
end
