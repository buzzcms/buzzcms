# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Buzzcms.Repo.insert!(%Buzzcms.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
Buzzcms.Repo.insert!(%Buzzcms.Schema.AuthProvider{value: "email"})
Buzzcms.Repo.insert!(%Buzzcms.Schema.Role{value: "admin"})
Buzzcms.Repo.insert!(%Buzzcms.Schema.Role{value: "contributor"})
Buzzcms.Repo.insert!(%Buzzcms.Schema.Role{value: "customer", is_default: true})

Buzzcms.DataImporter.import_from_dir(Path.join(File.cwd!(), "sample_data"))
