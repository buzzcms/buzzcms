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
  end

  scope "/" do
    pipe_through [:api, :graphql]
    forward "/graphql", Absinthe.Plug, schema: BuzzcmsWeb.Schema
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: BuzzcmsWeb.Schema
  end

  scope "/", BuzzcmsWeb do
    get("/images/:transform/:id", ImageController, :transform)
    get("/images/:id", ImageController, :view)
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
end
