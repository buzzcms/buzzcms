import Config

database_url = System.fetch_env!("DATABASE_URL")
secret_key_base = System.fetch_env!("SECRET_KEY_BASE")

smtp_server =
  case System.fetch_env("SMTP_SERVER") do
    {:ok, result} -> result
    _ -> "email-smtp.us-east-1.amazonaws.com"
  end

smtp_port =
  case System.fetch_env("SMTP_PORT") do
    {:ok, result} -> String.to_integer(result)
    _ -> 587
  end

smtp_username = System.fetch_env!("SMTP_USERNAME")
smtp_password = System.fetch_env!("SMTP_PASSWORD")

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

config :buzzcms_web, BuzzcmsWeb.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: smtp_server,
  port: smtp_port,
  username: smtp_username,
  password: smtp_password
