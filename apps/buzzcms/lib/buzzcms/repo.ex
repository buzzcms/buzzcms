defmodule Buzzcms.Repo do
  use Ecto.Repo,
    otp_app: :buzzcms,
    adapter: Ecto.Adapters.Postgres
end
