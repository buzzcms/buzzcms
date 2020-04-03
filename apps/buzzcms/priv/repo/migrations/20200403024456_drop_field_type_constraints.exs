defmodule Buzzcms.Repo.Migrations.DropFieldTypeConstraints do
  use Ecto.Migration

  def change do
    drop constraint(:field, :field_type)
  end
end
