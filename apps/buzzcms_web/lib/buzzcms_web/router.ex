defmodule BuzzcmsWeb.Router do
  use BuzzcmsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # pipeline :auth do
  #   plug Buzzcms.Auth.Pipeline
  # end

  pipeline :graphql do
    plug BuzzcmsWeb.Context
  end

  scope "/" do
    pipe_through [:api, :graphql]
    forward "/graphql", Absinthe.Plug, schema: BuzzcmsWeb.Schema
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: BuzzcmsWeb.Schema
  end
end
