defmodule BuzzcmsWeb.Router do
  use BuzzcmsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug BuzzcmsWeb.Auth.Pipeline
  end

  # pipeline :auth do
  #   plug BuzzcmsWeb.Auth.Pipeline
  # end

  pipeline :graphql do
    plug BuzzcmsWeb.Context
    plug BuzzcmsWeb.Cachex
  end

  scope "/" do
    pipe_through [:api, :graphql]

    forward "/graphql", Absinthe.Plug,
      schema: BuzzcmsWeb.Schema,
      document_providers: [
        BuzzcmsWeb.Schema.DocumentProvider.PersistedQueries,
        Absinthe.Plug.DocumentProvider.Default
      ]

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: BuzzcmsWeb.Schema,
      document_providers: [
        BuzzcmsWeb.Schema.DocumentProvider.PersistedQueries,
        Absinthe.Plug.DocumentProvider.Default
      ]
  end

  scope "/images", BuzzcmsWeb do
    get("/:transform/:id", ImageController, :transform)
    get("/:id", ImageController, :view)
  end

  scope "/images", BuzzcmsWeb do
    post("/upload", ImageController, :upload)
  end

  scope "/auth", BuzzcmsWeb do
    pipe_through [:api, :auth]

    get("/me", AuthController, :me)

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
    post("/:provider/callback", AuthController, :callback)
    post("/register", AuthController, :sign_up_with_email)
    post("/logout", AuthController, :delete)
    post("/verify", AuthController, :verify_token)
  end

  def absinthe_before_send(conn, %Absinthe.Blueprint{} = _blueprint) do
    # IO.inspect(conn, label: "Before send")
    conn
  end

  def absinthe_before_send(conn, _) do
    conn
  end
end
