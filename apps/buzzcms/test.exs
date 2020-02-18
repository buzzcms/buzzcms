# import Ecto.Query
# alias Buzzcms.Repo
# alias Buzzcms.Schema.{Entry, Taxon, EntryTaxon}

# taxon_id = 20

# queryable = EntryTaxon

# query =
#   from e in Entry,
#     join: ref in ^queryable,
#     on: e.id == ref.entry_id,
#     where: ref.taxon_id == ^taxon_id

# Repo.all(query) |> IO.inspect()
IO.inspect(Buzzcms.Schema.Entry.__struct__())
