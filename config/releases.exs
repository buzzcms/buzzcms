import Config

database_url = System.fetch_env!("DATABASE_URL")
secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

pool_size =
  case System.fetch_env("DB_POOL_SIZE") do
    {:ok, result} -> String.to_integer(result)
    _ -> 10
  end

config :buzzcms, Buzzcms.Repo,
  url: database_url,
  pool_size: pool_size

config :buzzcms_web, BuzzcmsWeb.Endpoint,
  http: [:inet6, port: 4000],
  url: [port: 4000],
  secret_key_base: secret_key_base,
  server: true
